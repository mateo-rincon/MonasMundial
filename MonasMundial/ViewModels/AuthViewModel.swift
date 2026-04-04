//
//  AuthViewModel.swift
//  ParkingApp
//
//  Created by Mateo on 19/02/26.
//
/*
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUser: User? = nil
    @Published var currentUserEmail: String? = nil
    @Published var requiresBiometricUnlock: Bool = false

    @AppStorage("biometricsEnabled") var biometricsEnabled: Bool = false

    var biometricType: LABiometryType {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return .none }
        return ctx.biometryType
    }

    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let firebaseUser = firebaseUser {
                self.currentUserEmail = firebaseUser.email
                Task { await self.fetchUserData(uid: firebaseUser.uid) }
            } else {
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.currentUser = nil
                    self.currentUserEmail = nil
                }
            }
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Fetch user data de MonasMundial
    func fetchUserData(uid: String) async {
        do {
            let docRef = db.collection("users").document(uid)
            let doc = try await docRef.getDocument()
            
            if let data = doc.data() {
                // Caso A: El usuario ya existe en Firestore
                let name = data["name"] as? String ?? "Coleccionista"
                let email = data["email"] as? String ?? ""
                
                await MainActor.run {
                    self.currentUser = User(id: uid, name: name, email: email)
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            } else {
                // Caso B: El usuario existe en Auth pero NO en Firestore (tu caso actual)
                print("DEBUG: Creando documento inicial para el nuevo usuario...")
                
                let newData: [String: Any] = [
                    "name": currentUserEmail?.components(separatedBy: "@").first ?? "Nuevo Usuario",
                    "email": currentUserEmail ?? "",
                    "totalLaminas": 0,
                    "repetidas": 0,
                    "faltantes": 638,
                    "createdAt": Timestamp()
                ]
                
                try await docRef.setData(newData)
                
                await MainActor.run {
                    self.currentUser = User(id: uid, name: newData["name"] as! String, email: newData["email"] as! String)
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error de Firestore: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    // MARK: - Autenticación (Email & Google)
    func signIn(username: String, password: String) async {
        await MainActor.run { self.isLoading = true; self.errorMessage = nil }
        
        // El 'defer' asegura que pase lo que pase, al final de la función isLoading sea false
        defer {
            DispatchQueue.main.async { self.isLoading = false }
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: username, password: password)
            // Si el login es exitoso, Firebase nos devuelve el usuario
            let uid = result.user.uid
            await fetchUserData(uid: uid) // Esta función debe cambiar isLoggedIn = true
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                // Aquí es donde solía quedarse colgado si no apagabas el loading
            }
        }
    }

    func signInWithGoogle() async {
        await MainActor.run { isLoading = true; errorMessage = nil }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        do {
            // 1. Iniciar sesión con Google
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
            // 2. OBTENER EL TOKEN (Aquí suele estar el error de 'malformed')
            // Asegúrate de usar 'idToken?.tokenString'
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el ID Token"])
            }

            // 3. Crear la credencial de Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            
            // 4. Autenticar en Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            let uid = authResult.user.uid
            
            // 5. Cargar o crear datos en Firestore
            await fetchUserData(uid: uid)
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error de autenticación: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // MARK: - Registro
    func register(name: String, email: String, password: String) async {
        await MainActor.run { isLoading = true }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            print("DEBUG: Usuario creado en Auth con UID: \(uid). Intentando escribir en Firestore...")

            try await db.collection("users").document(uid).setData([
                "name": name,
                "email": email,
                "totalLaminas": 0,
                "createdAt": Timestamp()
            ])
            
            print("DEBUG: ¡Escritura exitosa! La colección 'users' debería aparecer ahora.")
            
            await fetchUserData(uid: uid)
        } catch {
            print("DEBUG: Error en el proceso: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Biometría
    func authenticateWithBiometrics() async {
        let context = LAContext()
        let reason = "Desbloquea MonasMundial para ver tu álbum"

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if success {
                await MainActor.run {
                    self.requiresBiometricUnlock = false
                    self.errorMessage = nil
                }
            }
        } catch {
            await MainActor.run { self.errorMessage = "Autenticación biométrica fallida." }
        }
    }

    // MARK: - Sign Out
    @MainActor
    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        isLoggedIn = false
        currentUser = nil
        currentUserEmail = nil
        requiresBiometricUnlock = false
    }

    private func firebaseErrorMessage(_ error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case AuthErrorCode.wrongPassword.rawValue, AuthErrorCode.invalidCredential.rawValue:
            return "Email o contraseña incorrectos."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Este correo ya está registrado."
        default:
            return "Ocurrió un error. Intenta de nuevo."
        }
    }
}
*/
