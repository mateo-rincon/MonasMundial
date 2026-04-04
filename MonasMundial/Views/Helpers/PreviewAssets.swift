//
//  PreviewAssets.swift
//  MonasMundial
//
//  Created by Mateo on 3/04/26.
//

extension StickersViewModel {
    static var preview: StickersViewModel {
        let viewModel = StickersViewModel()
        
        // Creamos una estructura de prueba rápida
        let mockStickers = (1...20).map { Sticker(id: "test-\($0)", number: $0, count: Int.random(in: 0...2)) }
        let mockCountry = Country(id: "1", name: "México", code: "MEX", stickers: mockStickers)
        let mockGroup = AlbumGroup(id: "G1", name: "Grupo A", countries: [mockCountry])
        
        viewModel.groups = [mockGroup]
        
        // Forzamos el cálculo de stats para que el Dashboard se vea lleno
        var owned = 0
        var dupes = 0
        for sticker in mockStickers {
            if sticker.count > 0 { owned += 1 }
            if sticker.count > 1 { dupes += (sticker.count - 1) }
        }
        viewModel.statsOwned = owned
        viewModel.statsDuplicates = dupes
        
        return viewModel
    }
}
