//
//  StickersViewModel.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//
import Foundation
import Combine

import Foundation
import SwiftUI

class StickersViewModel: ObservableObject {
    
    // 📂 Estructura jerárquica con el 'count' dentro de cada Sticker
    @Published var groups: [AlbumGroup] = []
    
    // 📊 Stats para el Dashboard (Actualizadas síncronamente)
    @Published var statsOwned: Int = 0
    @Published var statsDuplicates: Int = 0
    
    let totalStickersConstant = 980
    private let fileManager = LocalFileManager()
    
    var missingCount: Int {
        totalStickersConstant - statsOwned
    }
    
    init() {
        loadData()
    }
    
    // MARK: - Persistencia Directa (Sin Hilos)
    func loadData() {
        if let savedInventory = fileManager.load() {
            self.groups = savedInventory.groups
            //self.groups = StickersViewModel.generateInitialStructure()
        } else {
            self.groups = StickersViewModel.generateInitialStructure()
        }
        recalculateFullStats()
    }
    
    func saveData() {
        // Correcto: StickerInventory espera 'groups'
        let inventory = StickerInventory(groups: self.groups)
        fileManager.save(inventory: inventory)
    }
    
    // MARK: - Actualización de Stickers
    // Al dividir por grupos, esta iteración es sumamente rápida
    func updateSticker(stickerID: String, delta: Int) {
        for gIndex in groups.indices {
            for cIndex in groups[gIndex].countries.indices {
                if let sIndex = groups[gIndex].countries[cIndex].stickers.firstIndex(where: { $0.id == stickerID }) {
                    
                    let oldVal = groups[gIndex].countries[cIndex].stickers[sIndex].count
                    let newVal = max(0, oldVal + delta)
                    
                    if oldVal != newVal {
                        // 1. Actualizamos el valor directamente
                        groups[gIndex].countries[cIndex].stickers[sIndex].count = newVal
                        
                        // 2. Actualizamos estadísticas en el mismo paso
                        updateIncrementalStats(old: oldVal, new: newVal)
                        
                        // 3. Feedback y Guardado instantáneo
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        saveData()
                    }
                    return
                }
            }
        }
    }
    
    private func updateIncrementalStats(old: Int, new: Int) {
        // Unidades únicas
        if old == 0 && new >= 1 { statsOwned += 1 }
        if old >= 1 && new == 0 { statsOwned -= 1 }
        
        // Repetidas (count - 1)
        let oldDupes = max(0, old - 1)
        let newDupes = max(0, new - 1)
        statsDuplicates += (newDupes - oldDupes)
    }
    
    private func recalculateFullStats() {
        let allStickers = groups.flatMap { $0.countries }.flatMap { $0.stickers }
        statsOwned = allStickers.filter { $0.count > 0 }.count
        statsDuplicates = allStickers.reduce(0) { $0 + max(0, $1.count - 1) }
    }
    
    
    // MARK: - Lógica de Intercambio (QR)
    func getDuplicatesForQR() -> StickerCollection {
        let duplicateIDs = groups.flatMap { $0.countries }
            .flatMap { $0.stickers }
            .filter { $0.count > 1 }
            .map { $0.id }
        
        // Correcto: StickerCollection es la que tiene el argumento 'duplicates'
        return StickerCollection(duplicates: duplicateIDs)
    }
    
    func findWhatServesMe(from others: StickerCollection) -> [String] {
        let allMyStickers = groups.flatMap { $0.countries }.flatMap { $0.stickers }
        return others.duplicates.filter { id in
            let mySticker = allMyStickers.first(where: { $0.id == id })
            return (mySticker?.count ?? 0) == 0
        }
    }
    
    // MARK: - Generador de Estructura (Plantilla)
    private static func generateInitialStructure() -> [AlbumGroup] {
        // 1. Definición del grupo especial inicial
        let specialGroupCode = "FWC"
        let specialCountry = Country(
            id: UUID().uuidString,
            name: "FIFA World Cup",
            code: specialGroupCode,
            stickers: (1...20).map { Sticker(id: "\(specialGroupCode) \($0)", number: $0, count: 0) }
        )
        
        let fwcGroup = AlbumGroup(
            id: "G-SPECIAL",
            name: "Especiales FWC",
            countries: [specialCountry]
        )
        
        // 2. Tu lista exacta de 48 países
        let rawData: [(name: String, code: String)] = [
            ("México", "MEX"), ("Sudáfrica", "RSA"), ("Corea del Sur", "KOR"), ("Chequia", "CHK"),
            ("Canadá", "CAN"), ("Bosnia", "BOS"), ("Qatar", "QAT"), ("Suiza", "SUI"),
            ("Brasil", "BRA"), ("Marruecos", "MAR"), ("Haití", "HAI"), ("Escocia", "SCO"),
            ("Estados Unidos", "USA"), ("Paraguay", "PAR"), ("Australia", "AUS"), ("Turquia", "TUR"),
            ("Alemania", "GER"), ("Curazao", "CUW"), ("Costa de Marfil", "CIV"), ("Ecuador", "ECU"),
            ("Países Bajos", "NED"), ("Japón", "JPN"), ("Suecia", "SWE"), ("Túnez", "TUN"),
            ("Bélgica", "BEL"), ("Egipto", "EGY"), ("Irán", "IRN"), ("Nueva Zelanda", "NZL"),
            ("España", "ESP"), ("Cabo Verde", "CPV"), ("Arabia Saudita", "KSA"), ("Uruguay", "URU"),
            ("Francia", "FRA"), ("Senegal", "SEN"), ("Irak", "IRK"), ("Noruega", "NOR"),
            ("Argentina", "ARG"), ("Argelia", "ALG"), ("Austria", "AUT"), ("Jordania", "JOR"),
            ("Portugal", "POR"), ("Congo", "COD"), ("Uzbekistán", "UZB"), ("Colombia", "COL"),
            ("Inglaterra", "ENG"), ("Croacia", "CRO"), ("Ghana", "GHA"), ("Panamá", "PAN")
        ]
        
        // Iniciamos el array con el grupo FWC
        var tempGroups: [AlbumGroup] = [fwcGroup]
        let itemsPerGroup = 4
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
        
        // 3. Proceso de agrupación de los países restantes
        for i in stride(from: 0, to: rawData.count, by: itemsPerGroup) {
            let groupIndex = i / itemsPerGroup
            let groupLetter = groupIndex < alphabet.count ? alphabet[groupIndex] : "\(groupIndex)"
            
            let endIndex = min(i + itemsPerGroup, rawData.count)
            let chunk = Array(rawData[i..<endIndex])
            
            let countriesInGroup = chunk.map { data in
                Country(
                    id: UUID().uuidString,
                    name: data.name,
                    code: data.code,
                    stickers: (1...20).map { Sticker(id: "\(data.code) \($0)", number: $0, count: 0) }
                )
            }
            
            let newGroup = AlbumGroup(
                id: "G-\(groupLetter)",
                name: "Grupo \(groupLetter)",
                countries: countriesInGroup
            )
            
            tempGroups.append(newGroup)
        }
        
        return tempGroups
    }
}

// MARK: - Helpers para la Vista (Corregidos para la nueva estructura)
extension StickersViewModel {
    
    func progress(for country: Country) -> Double {
        // Ahora el count vive dentro de cada sticker del país
        let ownedCount = country.stickers.filter { $0.count >= 1 }.count
        
        guard !country.stickers.isEmpty else { return 0 }
        return Double(ownedCount) / Double(country.stickers.count)
    }
    
    func progressLabel(for country: Country) -> String {
        "\(Int(progress(for: country) * 100))%"
    }
}

/*
 class StickersViewModel: ObservableObject {
 // El diccionario que almacena: ["COL 1": 2, "ARG 10": 1]
 @Published var userLaminas: [String: Int] = [:]
 
 // Lista de países para el álbum
 let countries = [
 Country(name: "Colombia", code: "COL"),
 Country(name: "Argentina", code: "ARG"),
 Country(name: "Brasil", code: "BRA"),
 Country(name: "Alemania", code: "GER")
 ]
 
 private let db = Firestore.firestore()
 
 // Sumar una lámina
 func addSticker(id: String) {
 let currentCount = userLaminas[id] ?? 0
 userLaminas[id] = currentCount + 1
 saveToFirestore(id: id, count: currentCount + 1)
 }
 
 // Restar una lámina
 func removeSticker(id: String) {
 let currentCount = userLaminas[id] ?? 0
 if currentCount > 0 {
 userLaminas[id] = currentCount - 1
 saveToFirestore(id: id, count: currentCount - 1)
 }
 }
 
 // Guardado persistente (funciona offline automáticamente)
 private func saveToFirestore(id: String, count: Int) {
 guard let uid = Auth.auth().currentUser?.uid else { return }
 
 db.collection("users").document(uid).updateData([
 "laminas.\(id)": count
 ]) { error in
 if let error = error { print("Error: \(error.localizedDescription)") }
 }
 }
 
 // Función auxiliar para el contador de la vista
 func countOwned(in country: Country) -> Int {
 let ids = (1...20).map { "\(country.code) \($0)" }
 return ids.filter { (userLaminas[$0] ?? 0) > 0 }.count
 }
 
 }
 */
