//
//  ContentView.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//

import SwiftUI


struct ContentView: View {
    // Instanciamos el ViewModel una sola vez aquí.
    // Al inicializarse, cargará automáticamente el JSON local.
    @StateObject private var stickersVM = StickersViewModel() // Inicialización completa
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground() // O .configureWithDefaultBackground()
        // Si quieres que la barra inferior sea oscura pero traslúcida:
        tabBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    var body: some View {
        TabView {
            // Pestaña 1: Dashboard (Resumen y Progreso)
            DashboardView(stickersVM: stickersVM)
                .tabItem {
                    Label("Progreso", systemImage: "chart.pie.fill")
                }
            
            // Pestaña 2: Álbum (La cuadrícula de láminas)
            AlbumGroupsView(vm: stickersVM)
                .tabItem {
                    Label("Mi Álbum", systemImage: "book.closed.fill")
                }
            
            // Pestaña 3: Intercambio (Aquí irá Multipeer después)
            IntercambiosView(vm: stickersVM)
                .tabItem {
                    Label("Intercambiar", systemImage: "person.line.dotted.person.fill")
                }
            // Pestaña 4: Sincronización Familiar (Manual vía Firebase)
            SincronizacionManualView(vm: stickersVM)
                .tabItem {
                    Label("Grupos", systemImage: "person.2.badge.key.fill")
                }
        }
        // Aplicamos un color global a los iconos de la TabBar
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}

/*

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var stickersVM = StickersViewModel() // Compartido por las pestañas
    
    var body: some View {
        Group {
            if authVM.isLoggedIn {
                TabView {
                    // Pestaña 1: Dashboard
                    DashboardView(stickersVM: stickersVM)
                        .tabItem {
                            Label("Inicio", systemImage: "house.fill")
                        }
                    
                    // Pestaña 2: Álbum Completo
                    AlbumView(stickersVM: stickersVM)
                        .tabItem {
                            Label("Álbum", systemImage: "book.closed.fill")
                        }
                    
                    // Pestaña 3: Amigos e Intercambios
                    FriendsView()
                        .tabItem {
                            Label("Amigos", systemImage: "person.2.fill")
                        }
                    
                    // Pestaña 4: Perfil de Usuario
                    ProfileView()
                        .tabItem {
                            Label("Perfil", systemImage: "person.crop.circle.fill")
                        }
                }
                .accentColor(.green) // Color futbolero para la pestaña activa
            } else {
                LoginView()
            }
        }
    }
}
#Preview {
    // 1. Creamos una instancia de prueba
    let mockAuth = AuthViewModel()
    
    // 2. Se la pasamos a la vista
    return LoginView()
        .environmentObject(mockAuth)
}
*/
