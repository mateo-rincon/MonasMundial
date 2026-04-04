//
//  StickerInventory.swift
//  MonasMundial
//
//  Created by Mateo on 1/04/26.
//
import Foundation


// 1. Sticker
struct Sticker: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let number: Int
    var count: Int
}

// 2. Country
struct Country: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let code: String
    var stickers: [Sticker]
}

// 3. AlbumGroup (Este es el que te pedía el error)
struct AlbumGroup: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    var countries: [Country]
}

struct StickerInventory: Codable {
    var groups: [AlbumGroup]
    
    // Estadísticas calculadas al vuelo
    var totalOwned: Int {
        groups.flatMap { $0.countries }.flatMap { $0.stickers }.filter { $0.count > 0 }.count
    }
    
    var totalDuplicates: Int {
        groups.flatMap { $0.countries }.flatMap { $0.stickers }.filter { $0.count > 1 }.map { $0.count - 1 }.reduce(0, +)
    }
}

struct StickerCollection: Codable {
    var duplicates: [String]
}

