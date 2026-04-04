//
//  DashboardView.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//
import SwiftUI


import SwiftUI

struct DashboardView: View {
    @ObservedObject var stickersVM: StickersViewModel
    
    // Proporción de progreso usando las nuevas variables rápidas
    private var progress: Double {
        stickersVM.totalStickersConstant > 0
        ? Double(stickersVM.statsOwned) / Double(stickersVM.totalStickersConstant)
        : 0
    }
    private var missingCount: Int {
        stickersVM.totalStickersConstant - stickersVM.statsOwned
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🔵 FONDO FIFA STYLE
                LinearGradient(
                    colors: [Color.mundialBlue.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 📱 CONTENIDO
                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Text("Mi Álbum")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Card Principal de Progreso
                        ProgressCard(
                            progress: progress,
                            owned: stickersVM.statsOwned,
                            total: stickersVM.totalStickersConstant
                        )
                        
                        // Grid de Faltantes y Repetidas
                        StatsGrid(
                            missing: missingCount,
                            duplicates: stickersVM.statsDuplicates
                        )
                        
                        // Sección de Top Selecciones
                        TopCountriesSection(vm: stickersVM)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - PROGRESS CARD
struct ProgressCard: View {
    let progress: Double
    let owned: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .blue.opacity(0.2), radius: 6)
                    .animation(.easeOut(duration: 1.2), value: progress)
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("\(owned) / \(total)")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            .frame(width: 200, height: 200)
            
            Text("PROGRESO TOTAL")
                .font(.caption2)
                .fontWeight(.black)
                .foregroundColor(.blue.opacity(0.8))
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

// MARK: - STATS GRID
struct StatsGrid: View {
    let missing: Int
    let duplicates: Int
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Faltantes",
                value: "\(missing)",
                icon: "bolt.fill",
                color: .orange
            )
            
            StatCard(
                title: "Repetidas",
                value: "\(duplicates)",
                icon: "square.stack.3d.up.fill",
                color: .green
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.8), radius: 10)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(color.opacity(0.5), lineWidth: 1.5)
        )
    }
}


// MARK: - TOP COUNTRIES SECTION (Adaptada a Grupos)
struct TopCountriesSection: View {
    @ObservedObject var vm: StickersViewModel
    
    var topCountries: [Country] {
        // 1. Extraemos todos los países de todos los grupos
        let allCountries = vm.groups.flatMap { $0.countries }
        
        // 2. Ordenamos por el progreso que devuelve el VM
        return allCountries.sorted {
            vm.progress(for: $0) > vm.progress(for: $1)
        }
        // 3. Tomamos los primeros 5
        .prefix(5)
        .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Selecciones")
                .font(.title3)
                .fontWeight(.black)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(Array(topCountries.enumerated()), id: \.element.id) { index, country in
                    let prog = vm.progress(for: country)
                    
                    HStack(spacing: 15) {
                        Text("#\(index + 1)")
                            .font(.caption).bold()
                            .foregroundColor(.white.opacity(0.7))
                        
                        // Usamos el código o los primeros 3 caracteres del nombre
                        Text(country.code.isEmpty ? String(country.name.prefix(3)).uppercased() : country.code)
                            .font(.caption).bold()
                            .foregroundColor(.black)
                            .frame(width: 40, height: 28)
                            .background(.white)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(country.name)
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(prog * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            ProgressView(value: prog)
                                .tint(prog > 0.8 ? .green : .blue)
                                .scaleEffect(y: 2)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(18)
                }
            }
        }
    }
}

// MARK: - PREVIEW ADAPTADO
#Preview {
    // Usamos un ZStack y fondo oscuro para que luzca como tu diseño original
    ZStack {
        Color.blue.opacity(0.7).ignoresSafeArea()
        
        DashboardView(stickersVM: StickersViewModel.preview)
    }
}
