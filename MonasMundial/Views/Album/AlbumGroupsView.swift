//
//  AlbumGroupsView.swift
//  MonasMundial
//
//  Created by Mateo on 3/04/26.
//
import SwiftUI

struct AlbumGroupsView: View {
    @ObservedObject var vm: StickersViewModel
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🔵 FONDO UNIFICADO (Mundial Blue)
                LinearGradient(
                    colors: [Color.mundialBlue.opacity(0.95), Color.mundialBlue.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // HEADER ADAPTADO
                        HStack {
                            Text("GRUPOS")
                                .font(.system(size: 32, weight: .black).width(.expanded))
                                .italic()
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // GRID DE GRUPOS
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(vm.groups) { group in
                                NavigationLink(value: group) {
                                    GroupCardViewRow(group: group, vm: vm)
                                }
                                .buttonStyle(ScaleButtonStyle()) // Animación al tocar
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(for: AlbumGroup.self) { group in
                GroupDetailView(vm: vm, groupID: group.id)
            }
        }
    }
}

// ✅ TARJETA CON ESTILO "GLASS" Y TIPOGRAFÍA EXPANDIDA
struct GroupCardViewRow: View {
    let group: AlbumGroup
    @ObservedObject var vm: StickersViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // PARTE SUPERIOR
            HStack(alignment: .firstTextBaseline) {
                Text(group.name)
                    .font(.system(size: 22, weight: .black).width(.expanded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Badge de cantidad (opcional pero se ve pro)
                Text("\(group.countries.count) PAÍSES")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // PAÍSES (En una sola línea, más discreto)
            Text(group.countries.map { $0.name }.joined(separator: " • ").uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.blue.opacity(0.8))
                .lineLimit(1)
            
            // PARTE INFERIOR: PROGRESO + CIRCULITOS
            HStack(spacing: 15) {
                let progress = calculateProgress()
                
                // Barra de progreso personalizada
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: progress)
                        .tint(.mundialGreen)
                        .scaleEffect(y: 2)
                    
                    Text("\(Int(progress * 100))% COMPLETADO")
                        .font(.system(size: 10, weight: .black).width(.expanded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // CÓDIGOS DE PAÍS (Avatar Style)
                HStack(spacing: -10) {
                    ForEach(Array(group.countries.prefix(4).enumerated()), id: \.offset) { index, country in
                        Text(country.code)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.mundialBlue.opacity(0.8))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.3)) // Estilo Glassmorphism
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func calculateProgress() -> Double {
        let stickers = group.countries.flatMap { $0.stickers }
        let owned = stickers.filter { $0.count > 0 }.count
        return stickers.isEmpty ? 0 : Double(owned) / Double(stickers.count)
    }
}

// ✅ ESTILO DE BOTÓN PARA REUTILIZAR LA ANIMACIÓN SPRING
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - PREVIEW
struct AlbumGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        // Simulamos el ViewModel con datos de prueba
        let mockVM = StickersViewModel()
        
        // Configuramos un par de grupos de prueba para el preview
        mockVM.groups = [
            AlbumGroup(id: "G1", name: "GRUPO A", countries: []),
            AlbumGroup(id: "G2", name: "GRUPO B", countries: []),
            AlbumGroup(id: "G3", name: "GRUPO C", countries: []),
            AlbumGroup(id: "G4", name: "ESPECIALES", countries: [])
        ]
        
        return NavigationStack {
            AlbumGroupsView(vm: mockVM)
        }
    }
}

