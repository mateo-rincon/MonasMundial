//
//  CircularProgressView.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//
import SwiftUI
struct CircularProgressView: View {
    let progress: Double // Valor de 0.0 a 1.0
    
    var body: some View {
        ZStack {
            // Círculo de fondo (el carril)
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
            
            // Círculo de progreso (la carga)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0))) // Limita a 100%
                .stroke(
                    Color.green,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90)) // Para que empiece arriba
                .animation(.linear, value: progress) // Animación suave
        }
    }
}
