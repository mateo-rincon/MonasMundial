//
//  LoginView.swift
//  ParkingApp
//
//  Created by Mateo on 19/02/26.
//
/*
import SwiftUI
import GoogleSignInSwift
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    private var biometricIcon: String {
        authVM.biometricType == .touchID ? "touchid" : "faceid"
    }

    private var biometricLabel: String {
        authVM.biometricType == .touchID ? "Entrar con Touch ID" : "Entrar con Face ID"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Spacer()

                // MARK: - Logo/Header (Adaptado a MonasMundial)
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "trophy.fill") // Icono de trofeo para el mundial
                            .font(.system(size: 70))
                            .foregroundColor(.yellow)
                    }
                    
                    VStack(spacing: 5) {
                        Text("MonasMundial")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Completa tu álbum con amigos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Formulario
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.green.opacity(0.7))
                            .frame(width: 30)
                        TextField("Correo electrónico", text: $email)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.green.opacity(0.7))
                            .frame(width: 30)
                        SecureField("Contraseña", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }

                // MARK: - Botón de Login (Estilo Futbolístico)
                Button {
                    Task { await authVM.signIn(username: email, password: password) }
                } label: {
                    HStack {
                        if authVM.isLoading {
                            ProgressView().tint(.white).padding(.trailing, 10)
                        }
                        Text(authVM.isLoading ? "Cargando..." : "¡A coleccionar!")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty || password.count < 6 ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .disabled(authVM.isLoading || email.isEmpty || password.count < 6)
                .padding(.horizontal, 24)

                // MARK: - Divisor
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("o únete con").font(.caption).foregroundColor(.secondary)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 24)

                // MARK: - Redes Sociales y Biometría
                VStack(spacing: 12) {
                    // Google
                    Button {
                        Task { await authVM.signInWithGoogle() }
                    } label: {
                        HStack(spacing: 12) {
                            //Image("Google_Logo") // Asegúrate de tener este asset
                                //.resizable()
                                //.scaledToFit()
                                //.frame(width: 20, height: 20)
                            Text("Continuar con Google")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // FaceID / TouchID
                    if authVM.biometricsEnabled {
                        Button {
                            Task { await authVM.authenticateWithBiometrics() }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: biometricIcon)
                                    .font(.system(size: 20))
                                Text(biometricLabel)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.green)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Registro
                NavigationLink {
                    RegistrationView()
                } label: {
                    HStack {
                        Text("¿Eres nuevo coleccionista?")
                        Text("Regístrate")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.green)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }

        #if DEBUG
        VStack(spacing: 12) {
            Text("Modo Desarrollador")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button("Entrar como Usuario") {
                    Task {
                            // CORRECCIÓN: Pasar 'name' como primer argumento
                            await authVM.register(name: name, email: email, password: password)
                        }}
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
        }
        .padding(.top, 20)
        #endif
    }
}

// Componente para campos de texto normales
struct CustomTextField: View {
    var imageName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.green.opacity(0.7))
                .frame(width: 30)
            TextField(placeholder, text: $text)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Componente para campos de contraseña
struct CustomSecureField: View {
    var imageName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.green.opacity(0.7))
                .frame(width: 30)
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
*/
