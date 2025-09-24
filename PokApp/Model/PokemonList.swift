//
//  PokemonList.swift
//  PokApp
//
//  Created by Nikash Yogesh Ramsorrun on 24/09/2025.
//

import Foundation

struct PokemonList: Decodable, Equatable {
    let results: [PokemonEntryPoint]
}

extension PokemonList {
    static func mock(
        results: [PokemonEntryPoint] = []
    ) -> Self {
        .init(results: results)
    }
}

struct PokemonListRequest: Request {
    typealias ReturnType = PokemonList
    let path: String = "/pokemon"
}
