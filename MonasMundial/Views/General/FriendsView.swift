//
//  FriendsView.swift
//  MonasMundial
//
//  Created by Mateo on 29/03/26.
//
import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Aquí verás a tus amigos y quién tiene tus faltantes")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Mis Amigos")
        }
    }
}
