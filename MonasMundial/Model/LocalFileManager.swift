//
//  LocalFileManager.swift
//  MonasMundial
//
//  Created by Mateo on 1/04/26.
//
import Foundation


class LocalFileManager {
    private let fileName = "album_data.json"
    
    private var filePath: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent(fileName)
    }
    
    // Guarda el inventario completo
    func save(inventory: StickerInventory) {
        guard let url = filePath else { return }
        do {
            let data = try JSONEncoder().encode(inventory)
            try data.write(to: url, options: [.atomicWrite])
        } catch {
            print("Error al guardar: \(error)")
        }
    }
    
    // Carga el inventario completo
    func load() -> StickerInventory? {
        guard let url = filePath, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(StickerInventory.self, from: data)
    }
}
