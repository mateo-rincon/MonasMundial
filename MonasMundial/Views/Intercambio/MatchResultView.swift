//
//  MatchResultView.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI

struct MatchResultView: View {
    // La tupla con los resultados de la comparación
    let result: (theyCanGiveMe: [String], iCanGiveThem: [String])
    
    // Acción para cerrar la vista o volver al escáner
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 25) {
            // Título Principal con el estilo del Dashboard
            Text("Resultado del Match")
                .font(.system(size: 28, weight: .black, ))
                .foregroundColor(.white)
                .padding(.top, 30)

            HStack(spacing: 15) {
                // PANEL: LO QUE RECIBES (Verde Repetidas)
                ResultCard(
                    title: "Te pueden dar",
                    count: result.theyCanGiveMe.count,
                    color: Color.mundialGreen,
                    icon: "arrow.down.circle.fill"
                )

                
            }
            .padding(.horizontal)

            // LISTA DETALLADA CON ESTILO GLASS
            if !result.theyCanGiveMe.isEmpty || !result.iCanGiveThem.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Label("DETALLES DEL INTERCAMBIO", systemImage: "list.bullet.rectangle.stack")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white.opacity(0.6))
                        //.letterSpacing(1)
                    
                    // Scroll de lo que recibes
                    DetailRow(items: result.theyCanGiveMe, color: .mundialGreen, label: "Recibes:")
                    
                    
                }
                .padding()
                .background(Color.black.opacity(0.3)) // Fondo oscuro traslúcido
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
            }

            Spacer()

            // Botón ACEPTAR con tu color Púrpura/Mundial
            Button(action: { onDismiss?() }) {
                Text("FINALIZAR")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.mundialGreen, .mundialGreen.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(18)
                    .shadow(color: .mundialPurple.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                // Fondo consistente con el resto de la App
                Color.mundialBlue.opacity(0.8).ignoresSafeArea()
                
                // Brillo decorativo
                RadialGradient(colors: [Color.mundialPurple.opacity(0.15), .clear], center: .topTrailing, startRadius: 0, endRadius: 400)
                    .ignoresSafeArea()
            }
        )
    }
}

// Sub-vista para las tarjetas de conteo (Glass Edition)
struct ResultCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            // Icono simple y directo
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                // El número es el protagonista absoluto
                Text("\(count)")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                
                Text("LÁMINAS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        // Fondo sólido semitransparente (más legible que el degradado)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        // Borde fino y constante
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// Fila de detalle para las láminas
struct DetailRow: View {
    let items: [String]
    let color: Color
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if items.isEmpty {
                        Text("Nada que intercambiar")
                            .font(.footnote)
                            .italic()
                            .foregroundColor(.white.opacity(0.3))
                    } else {
                        ForEach(items, id: \.self) { id in
                            Text(id)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(color.opacity(0.3))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.5), lineWidth: 1))
                        }
                    }
                }
            }
        }
    }
}

// Preview actualizado
struct MatchResultView_Previews: PreviewProvider {
    static var previews: some View {
        MatchResultView(result: (
            theyCanGiveMe: ["ARG1", "COL10", "BRA5", "FRA7"],
            iCanGiveThem: ["MEX2", "USA1"]
        ))
    }
}
