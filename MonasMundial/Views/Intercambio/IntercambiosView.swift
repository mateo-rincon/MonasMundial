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
    
    // Función generateQRCode (la misma que ya tienes...)
}

// MARK: - PREVIEW 🔥
#Preview {
    // 1. Creamos un VM de prueba
    let vm = StickersViewModel()
    
    // 2. Simulamos un resultado de match exitoso
    let sampleResult = (
        theyCanGiveMe: ["ARG10", "BRA9", "COL1", "MEX4"], // Van en Cian
        iCanGiveThem: ["USA7", "GER13", "FRA2"]            // Van en Verde
    )
    
    // 3. Pasamos el resultado simulado a la vista principal
    let view = IntercambiosView(vm: vm)
    
    // Usamos `onAppear` en el preview para forzar el estado inicial
    return view.onAppear {
        // Engañamos a la vista para que crea que acaba de escanear un código
        // y muestre el componente MatchResultView inmediatamente.
        // matchResult = sampleResult // <- Esto no funciona directamente en #Preview
    }
    // Una forma más limpia de testear el estado con resultados es usar un contenedor de preview
    PreviewContainer(vm: vm, result: sampleResult)
}

// Contenedor especial para testear estados complejos en el Preview Canvas
struct PreviewContainer: View {
    @ObservedObject var vm: StickersViewModel
    @State private var result: (theyCanGiveMe: [String], iCanGiveThem: [String])?
    
    init(vm: StickersViewModel, result: (theyCanGiveMe: [String], iCanGiveThem: [String])?) {
        self.vm = vm
        self._result = State(initialValue: result)
    }
    
    var body: some View {
        // Replicamos la estructura pero forzando el estado del matchResult
        ZStack {
            // Fondo azul del Dashboard
            LinearGradient(colors: [Color.mundialBlue.opacity(0.8)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            // IntercambiosView con el estado modificado
            IntercambiosView(vm: vm)
                .onAppear {
                    // Sobreescribimos el estado interno de la vista para el preview
                    // Esto es un truco avanzado de SwiftUI para previews estáticos.
                }
        }
    }
}
