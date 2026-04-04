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
    }
}
struct CompactStickerButton: View {
    let sticker: Sticker
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    @State private var isPressed = false
    
    // 💡 Calculamos una escala base: si la tiene, que sea 1.0 (o 1.02 para que resalte)
    // Si no la tiene, la dejamos en 1.0 exacta.
    private var baseScale: CGFloat {
        sticker.count > 0 ? 1.0 : 1.0
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // --- FONDO BASE (Para que el tamaño sea siempre constante) ---
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.1)) // Fondo neutro para las que no están
                .aspectRatio(0.75, contentMode: .fit)
            
            // --- CUERPO DEL STICKER ---
            RoundedRectangle(cornerRadius: 8)
                .fill(sticker.count > 0 ? Color.mundialGreen : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        // 💡 Cambiamos el color del borde para que no sea tan invasivo
                        .stroke(sticker.count > 0 ? Color.white.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1.2)
                )
                // 💡 La sombra ahora es exterior para que el sticker "crezca" hacia afuera
                .shadow(color: sticker.count > 0 ? Color.mundialGreen.opacity(0.4) : .clear, radius: sticker.count > 0 ? 5 : 0)
            
            // --- NÚMERO ---
            VStack {
                Spacer()
                Text("\(sticker.number)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .monospacedDigit()
                    // 💡 Si la tiene, usamos un color más oscuro para contraste, si no, blanco traslúcido
                    .foregroundColor(sticker.count > 0 ? Color.black.opacity(0.6) : .white.opacity(0.2))
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // --- BADGE DE REPETIDAS ---
            if sticker.count > 1 {
                Text("\(sticker.count)")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.mundialOrange)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .offset(x: 5, y: -5)
            }
        }
        // 💡 Aplicamos la escala base + el efecto de presión
        .scaleEffect(isPressed ? 0.95 : baseScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressed = $0 }) {
            if sticker.count > 0 {
                onRemove()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .onTapGesture {
            isPressed = true
            onAdd()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isPressed = false }
        }
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
