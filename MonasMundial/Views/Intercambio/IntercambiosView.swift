//
//  IntercambiosView.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI


// MARK: - MAIN VIEW
struct IntercambiosView: View {
    @ObservedObject var vm: StickersViewModel
    @State private var matchResult: (theyCanGiveMe: [String], iCanGiveThem: [String])?
    @State private var showScanner = false

    var body: some View {
        ZStack {
            Color.mundialBlue.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. HEADER CUSTOM (El estilo que te gustó)
                HStack {
                    Text("Intercambios")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        
                        // 2. TU QR (SIEMPRE VISIBLE)
                        VStack(spacing: 10) {
                            Text("TU CÓDIGO")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.white.opacity(0.6))
                                //.letterSpacing(2)

                            if let qrImage = generateQRCode(from: vm.getDuplicatesForQR()) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 320, height: 320) // Tamaño optimizado
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                            
                            Text("Deja que tu amigo escanee esto")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                        
                        // 3. BOTÓN PARA ESCANEAR AL OTRO
                        Button(action: { showScanner = true }) {
                            Label("ESCANEAR A MI AMIGO", systemImage: "qrcode.viewfinder")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mundialGreen)
                                .cornerRadius(15)
                        }

                        // 4. RESULTADOS (APARECEN AQUÍ ABAJO SIN TAPAR TU QR)
                        if let result = matchResult {
                            MatchResultView(result: result) {
                                self.matchResult = nil // Botón para limpiar y buscar otro
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            // Estado de espera
                            VStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.1))
                                Text("Esperando escaneo...")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerScreen(vm: vm) { result in
                withAnimation(.spring()) {
                    self.matchResult = result
                }
            }
        }
    }
    
}




