//
//  Utils.swift
//  MonasMundial
//
//  Created by Mateo on 2/04/26.
//

import Foundation
func countryPrefix(from country: String) -> String {
    
    let custom: [String: String] = [
        "FWC": "FWC",
        "México": "MEX",
        "Sudáfrica": "RSA",
        "Corea del Sur": "KOR",
        "Chequia":"CHK",
        "Canadá": "CAN",
        "Bosnia":"BOS",
        "Qatar": "QAT",
        "Suiza": "SUI",
        "Brasil": "BRA",
        "Marruecos": "MAR",
        "Haití": "HAI",
        "Escocia": "SCO",
        "Estados Unidos": "USA",
        "Paraguay": "PAR",
        "Australia": "AUS",
        "Turquia":"TUR",
        "Alemania": "GER",
        "Curazao": "CUW",
        "Costa de Marfil": "CIV",
        "Ecuador": "ECU",
        "Países Bajos": "NED",
        "Japón": "JPN",
        "Suecia": "SWE",
        "Túnez": "TUN",
        "Bélgica": "BEL",
        "Egipto": "EGY",
        "Irán": "IRN",
        "Nueva Zelanda": "NZL",
        "España": "ESP",
        "Cabo Verde": "CPV",
        "Arabia Saudita": "KSA",
        "Uruguay": "URU",
        "Francia": "FRA",
        "Senegal": "SEN",
        "Irak":"IRK",
        "Noruega": "NOR",
        "Argentina": "ARG",
        "Argelia": "ALG",
        "Austria": "AUT",
        "Jordania": "JOR",
        "Portugal": "POR",
        "Congo": "COD",
        "Uzbekistán": "UZB",
        "Colombia": "COL",
        "Inglaterra": "ENG",
        "Croacia": "CRO",
        "Ghana": "GHA",
        "Panamá": "PAN"
    ]
    
    
    
    return custom[country] ??
        country
            .uppercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: " ", with: "")
            .prefix(3)
            .description
}

import UIKit
import CoreImage.CIFilterBuiltins

func generateQRCode(from collection: StickerCollection) -> UIImage? {
    let encoder = JSONEncoder()
    
    guard let data = try? encoder.encode(collection) else { return nil }
    
    let filter = CIFilter.qrCodeGenerator()
    filter.setValue(data, forKey: "inputMessage")
    
    guard let outputImage = filter.outputImage else { return nil }
    
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaled = outputImage.transformed(by: transform)
    
    let context = CIContext()
    
    if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
        return UIImage(cgImage: cgImage)
    }
    
    return nil
}

