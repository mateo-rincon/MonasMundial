//
//  HomeView.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI

struct HomeView: View {
    @StateObject var vm = StickersViewModel()
    
    @State private var showQR = false
    @State private var showScanner = false
    @State private var matchResult: (theyCanGiveMe: [String], iCanGiveThem: [String])?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Intercambio de Stickers")
                    .font(.title)
                
                Button("Mostrar mi QR") {
                    showQR = true
                }
                
                Button("Escanear QR") {
                    showScanner = true
                }
                
                // 🔥 Resultado
                if let result = matchResult {
                    MatchResultView(result: result)
                }
            }
            .sheet(isPresented: $showQR) {
                MyQRView(vm: vm)
            }
            .sheet(isPresented: $showScanner) {
                ScannerScreen(vm: vm) { result in
                    self.matchResult = result
                }
            }
        }
    }
}
