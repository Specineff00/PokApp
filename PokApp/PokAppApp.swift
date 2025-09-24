//
//  PokAppApp.swift
//  PokApp
//
//  Created by Nikash Yogesh Ramsorrun on 24/09/2025.
//

import ComposableArchitecture
import SwiftUI

@main
struct PokAppApp: App {
    @MainActor
    static let store = Store(
        initialState: PokemonListFeature.State(),
        reducer: PokemonListFeature.init
    )
    var body: some Scene {
        WindowGroup {
            PokemonListView(store: Self.store)
        }
    }
}
