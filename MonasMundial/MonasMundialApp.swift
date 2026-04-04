//
//  MonasMundialApp.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn // No olvides importar esto aquí también

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MonasMundialApp: App {
    //@StateObject var authVM = AuthViewModel()
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            // Quitamos el NavigationView de aquí para evitar conflictos con el TabView
            ContentView()
                //.preferredColorScheme(.dark)
                //.environmentObject(authVM)
                //.onOpenURL { url in
                    // Maneja el retorno de Google Sign-In
                    //GIDSignIn.sharedInstance.handle(url)
                
        }
    }
}
