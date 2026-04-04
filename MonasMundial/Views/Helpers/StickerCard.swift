//
//  StickerCard.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//
/*
import SwiftUI
struct StickerCard: View {
    let id: String
    let number: Int
    let count: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    // Lógica visual basada en el conteo local
    var status: StickerStatus {
        if count == 0 { return .missing }
        if count == 1 { return .owned }
        return .duplicate
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(number)")
                .font(.system(.headline, design: .rounded))
            
            if count > 1 {
                Text("+\(count - 1)")
                    .font(.caption2).bold()
                    .padding(4)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(status.color) // Usamos la propiedad que creamos en el Enum
        .cornerRadius(12)
        .foregroundColor(status == .missing ? .primary : .white)
        .shadow(color: .black.opacity(0.05), radius: 2)
        .onTapGesture {
            onAdd() // Tap simple agrega
        }
        .onLongPressGesture {
            onRemove() // Mantener presionado quita una
        }
    }
}
*/




