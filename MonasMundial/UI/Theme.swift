//
//  Theme.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI

// ✅ Extensión de Colores basada en tu imagen del Mundial 2026
extension Color {
    static let mundialPurple = Color(red: 0.5, green: 0.2, blue: 0.9)
    static let mundialBlue = Color(red: 0.1, green: 0.4, blue: 0.9)
    static let mundialGreen = Color(red: 0.6, green: 0.9, blue: 0.1) // Verde Lima
    static let mundialOrange = Color(red: 1.0, green: 0.4, blue: 0.0)
    static let mundialBackground = Color(.systemGroupedBackground)
}

// ✅ Fondo común para todas tus vistas
// Crea un archivo "Styles.swift" o similar
struct MundialBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.mundialBlue.opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// ✅ Estilo de botón reutilizable
struct MundialButtonStyle: ButtonStyle {
    var color: Color = .mundialPurple
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}
