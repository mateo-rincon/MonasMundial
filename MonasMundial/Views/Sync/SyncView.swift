//
//  SyncView.swift
//  MonasMundial
//
//  Created by Mateo on 30/04/26.
//

import SwiftUI


struct SincronizacionManualView: View {
    @ObservedObject var vm: StickersViewModel
    @State private var syncManager = FirebaseSyncManager()
    
    @State private var inputCode: String = ""
    @State private var isUploading = false
    @State private var isDownloading = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showConfirmOverwrite = false

    // Foco para el teclado
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.mundialBlue.opacity(0.9).ignoresSafeArea()
                .onTapGesture { isTextFieldFocused = false } // Bajar teclado al tocar fondo
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        if vm.isSharedMode {
                            activeConnectionInfoCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        if !vm.isSharedMode {
                            VStack(spacing: 30) {
                                // SECCIÓN: CREAR
                                VStack(spacing: 15) {
                                    labelEstilo("¿QUIERES COMPARTIR TU ÁLBUM?")
                                    
                                    Button(action: generarYConectar) {
                                        VStack(spacing: 12) {
                                            if isUploading {
                                                ProgressView().tint(.white)
                                            } else {
                                                Image(systemName: "shareplay").font(.largeTitle)
                                                Text("CREAR ÁLBUM COMPARTIDO").font(.system(size: 14, weight: .black))
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 30)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundColor(.white.opacity(0.3))
                                        )
                                    }
                                    .disabled(isUploading)
                                }
                                
                                HStack {
                                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                                    Text("O").font(.caption2.bold()).foregroundColor(.white.opacity(0.3))
                                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                                }
                                
                                // SECCIÓN: UNIRSE
                                VStack(spacing: 15) {
                                    labelEstilo("INGRESAR A UN GRUPO EXISTENTE")
                                    
                                    TextField("CÓDIGO", text: $inputCode)
                                        .font(.system(size: 30, weight: .bold, design: .monospaced))
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.numberPad)
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .focused($isTextFieldFocused) // Vincular foco
                                        .onChange(of: inputCode) { newValue in
                                            if newValue.count > 6 { inputCode = String(newValue.prefix(6)) }
                                        }
                                    
                                    Button(action: validarYUnirse) {
                                        HStack {
                                            if isDownloading {
                                                ProgressView().tint(.black)
                                            } else {
                                                Image(systemName: "person.3.fill")
                                                Text("CONECTAR")
                                            }
                                        }
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(inputCode.count == 6 ? Color.mundialGreen : Color.gray)
                                        .cornerRadius(15)
                                    }
                                    .disabled(inputCode.count < 6 || isDownloading)
                                }
                            }
                            .padding(25)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(25)
                        } else {
                            Spacer(minLength: 50)
                            
                            Button(action: { vm.disconnectFromFamily() }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.left.circle.fill")
                                    Text("SALIR DEL MODO FAMILIAR")
                                }
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.red)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 30)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3)))
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(20)
                }
            }
        }
        // Toolbar para bajar el teclado
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") {
                    isTextFieldFocused = false
                }
            }
        }
        .animation(.spring(), value: vm.isSharedMode)
        // ALERTA 1: Confirmación de Merge
        .alert("¿Sincronizar?", isPresented: $showConfirmOverwrite) {
            Button("CANCELAR", role: .cancel) { }
            Button("SÍ, CONECTAR", role: .destructive) {
                vm.unirseAGrupo(id: inputCode)
            }
        } message: {
            Text("Esto reemplazará tu progreso actual con los datos del grupo familiar.")
        }
        // ALERTA 2: Errores (AQUÍ ESTABA EL FALLO)
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // --- LÓGICA CON ALERTAS REPARADAS ---

    func generarYConectar() {
        isUploading = true
        let nuevoID = Int.random(in: 100000...999999).description
        
        syncManager.uploadForSync(groups: vm.groups, sessionID: nuevoID) { success in
            DispatchQueue.main.async {
                self.isUploading = false
                if success {
                    vm.connectToFamily(sessionID: nuevoID)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } else {
                    // Ahora sí disparamos la alerta
                    self.alertMessage = "No se pudo crear el grupo. Revisa tu conexión."
                    self.showAlert = true
                }
            }
        }
    }

    func validarYUnirse() {
        isDownloading = true
        syncManager.downloadForSync(sessionID: inputCode) { grupos in
            DispatchQueue.main.async {
                self.isDownloading = false
                if grupos != nil {
                    self.showConfirmOverwrite = true
                } else {
                    // Ahora sí disparamos la alerta si el código no existe
                    self.alertMessage = "El código ingresado no es válido o el grupo ya no existe."
                    self.showAlert = true
                }
            }
        }
    }

    // (Tus componentes de View: headerView, activeConnectionInfoCard, labelEstilo se mantienen igual)
    var activeConnectionInfoCard: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle().fill(Color.mundialGreen).frame(width: 8, height: 8)
                    Text("SINCRONIZACIÓN ACTIVA").font(.system(size: 10, weight: .black))
                        .foregroundColor(.mundialGreen)
                }
                Text("Código: \(vm.currentSessionID ?? "")")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.title2)
                .foregroundColor(.mundialGreen)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1)))
    }

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Familia")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .italic()
                    .foregroundColor(.white)
                Text("LIVE CLOUD SYNC")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(3)
                    .foregroundColor(.mundialGreen)
                    .padding(.leading, 2)
            }
            Spacer()
        }
        .padding(.horizontal, 25).padding(.top, 40)
    }

    func labelEstilo(_ texto: String) -> some View {
        Text(texto).font(.system(size: 10, weight: .heavy)).foregroundColor(.white.opacity(0.4)).tracking(2).frame(maxWidth: .infinity, alignment: .leading)
    }
}
