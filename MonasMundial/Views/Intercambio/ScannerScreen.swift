//
//  ScannerScreen.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//
import SwiftUI
import Foundation


import SwiftUI

struct ScannerScreen: View {
    @ObservedObject var vm: StickersViewModel
    var onResult: ((theyCanGiveMe: [String], iCanGiveThem: [String])) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // Cambiamos (scannedString: String) por (otherCollection: StickerCollection)
        QRScannerView(vm: vm) { (otherCollection: StickerCollection) in
            
            // 1. Ya no necesitas .data(using:) ni JSONDecoder aquí
            // porque ScannerVC ya te entrega el objeto listo.
            
            // 2. Calculamos qué me sirve a MÍ usando la lógica de "Solo Repetidas"
            let itemsForMe = vm.findWhatServesMe(from: otherCollection)
            
            // 3. Regresamos al hilo principal para actualizar la interfaz
            DispatchQueue.main.async {
                // Enviamos el resultado (el segundo arreglo va vacío por la nueva lógica)
                onResult((theyCanGiveMe: itemsForMe, iCanGiveThem: []))
                dismiss()
            }
        }
        .ignoresSafeArea()
    }
    // MARK: - Preview
    struct ScannerScreen_Previews: PreviewProvider {
        static var previews: some View {
            ScannerScreen(vm: StickersViewModel()) { result in
                print("Matches encontrados: \(result.theyCanGiveMe.count)")
            }
        }
    }
    
}
