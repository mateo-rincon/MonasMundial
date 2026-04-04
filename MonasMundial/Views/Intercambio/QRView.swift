//
//  QRView.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI
import CoreImage.CIFilterBuiltins

struct MyQRView: View {
    @ObservedObject var vm: StickersViewModel
    
    var body: some View {
        ZStack {
            // Fondo Púrpura con un gradiente para dar profundidad
            LinearGradient(
                colors: [Color.mundialPurple, Color.mundialPurple.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Elemento decorativo de fondo
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -250)

            VStack(spacing: 30) {
                // Indicador para cerrar el sheet (barra gris arriba)
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                VStack(spacing: 8) {
                    Text("MI CÓDIGO")
                        .font(.system(size: 14, weight: .black))
                        //.letterSpacing(2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Repetidas")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // ✅ CONTENEDOR DEL QR
                ZStack {
                    // Brillo detrás del QR
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 310, height: 310)
                        .blur(radius: 20)
                    
                    if let qrImage = generateQRCode(from: vm.getDuplicatesForQR()) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 260, height: 260)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    } else {
                        // Estado de error estético
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                            Text("Error al generar")
                        }
                        .frame(width: 280, height: 280)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Pide a tu amigo que escanee este código.")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Al hacerlo, la app comparará tus repetidas con las láminas que a él le faltan automáticamente.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Texto de marca sutil
                Text("MUNDIAL 2026 • ÁLBUM DIGITAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
    
    // MARK: - Generador de QR (Lógica intacta, solo limpieza)
    func generateQRCode(from collection: StickerCollection) -> UIImage? {
        guard let data = try? JSONEncoder().encode(collection) else { return nil }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M" // Balance perfecto entre densidad y lectura
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

// MARK: - PREVIEW
#Preview {
    MyQRView(vm: StickersViewModel())
}
