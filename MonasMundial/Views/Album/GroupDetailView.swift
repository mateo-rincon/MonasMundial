//
//  GroupDetailView.swift
//  MonasMundial
//
//  Created by Mateo on 3/04/26.
//

import SwiftUI

struct GroupDetailView: View {
    @ObservedObject var vm: StickersViewModel
    let groupID: String
    
    init(vm: StickersViewModel, groupID: String) {
        self.vm = vm
        self.groupID = groupID
        
        // Configuramos la apariencia para iOS 15/16
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Esto quita la línea divisoria y aplica el estilo al "Back"
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white // Color del botón "Back"
    }
    var body: some View {
        ZStack {
            // 🔵 USAMOS EL MISMO FONDO QUE EL DASHBOARD
            LinearGradient(
                colors: [Color.mundialBlue.opacity(0.95), Color.mundialBlue.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let currentGroup = vm.groups.first(where: { $0.id == groupID }) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // TÍTULO DEL GRUPO
                        Text(currentGroup.name)
                            .font(.system(size: 36, weight: .black).width(.expanded))
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                            .overlay(
                                Rectangle()
                                    .frame(height: 4)
                                    .foregroundColor(.mundialGreen)
                                    .offset(y:0)
                                , alignment: .bottomLeading
                            ).padding()
                        
                        
                        ForEach(currentGroup.countries) { country in
                            VStack(alignment: .leading, spacing: 15) {
                                
                                // HEADER DE PAÍS (Ahora con estilo de tarjeta sutil)
                                HStack {
                                    Text(country.name)
                                        .font(.system(size: 32, weight: .black).width(.expanded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text(vm.progressLabel(for: country))
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                .padding(.horizontal)

                                // GRID DE STICKERS
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 12) {
                                    ForEach(country.stickers) { sticker in
                                        CompactStickerButton(
                                            sticker: sticker,
                                            onAdd: { vm.updateSticker(stickerID: sticker.id, delta: 1) },
                                            onRemove: { vm.updateSticker(stickerID: sticker.id, delta: -1) }
                                        )
                                        .id("\(sticker.id)-\(sticker.count)")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        // 💡 Si usas un TabView, esto limpia la barra inferior:
        .toolbarBackground(.hidden, for: .tabBar)
    }
}
struct CompactStickerButton: View {
    let sticker: Sticker
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // --- CUERPO DEL STICKER ---
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(sticker.count > 0 ? Color.mundialGreen.gradient : Color.white.opacity(0.08).gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(sticker.count > 0 ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                VStack {
                    Spacer()
                    Text("\(sticker.number)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(sticker.count > 0 ? .white : .white.opacity(0.2))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                if sticker.count > 1 {
                    Text("+\(sticker.count - 1)")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .offset(x: 4, y: 4)
                }
            }
            // 💡 Ajuste de escala: un poco menos agresivo para evitar el "pop"
            .scaleEffect(isPressed ? 0.94 : 1.0)
            // 💡 Muelle más orgánico: response 0.35, damping 0.6
            .animation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
            .onTapGesture {
                isPressed = true
                onAdd()
                
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // El retraso debe ser suficiente para que el usuario vea el hundimiento
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isPressed = false
                }
            }

            // --- BOTÓN DE REDUCIR ---
            if sticker.count > 0 {
                Button(action: {
                    withAnimation(.snappy) {
                        onRemove()
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.red.gradient)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .offset(x: -8, y: -8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(0.72, contentMode: .fit)
    }
}
struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockVM = StickersViewModel()
        
        // Datos de prueba para el Preview
        let stickers1 = [
            Sticker(id: "1", number: 1, count: 1),
            Sticker(id: "2", number: 2, count: 0),
            Sticker(id: "3", number: 3, count: 3), // Repetida
            Sticker(id: "4", number: 4, count: 0),
            Sticker(id: "5", number: 5, count: 1)
        ]
        
        let country = Country(id: "C1", name: "Sudáfrica", code: "RSA", stickers: stickers1)
        let group = AlbumGroup(id: "G1", name: "GRUPO A", countries: [country])
        
        mockVM.groups = [group]
        
        return NavigationStack {
            GroupDetailView(vm: mockVM, groupID: "G1")
        }
    }
}
