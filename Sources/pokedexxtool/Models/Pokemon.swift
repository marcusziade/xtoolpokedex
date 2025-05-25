import Foundation

struct PokemonListResponse: Codable {
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String { name }
    var pokemonId: Int {
        let components = url.split(separator: "/")
        return Int(components.last ?? "0") ?? 0
    }
}

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [PokemonType]
    let stats: [Stat]
    
    var imageUrl: String {
        sprites.frontDefault ?? ""
    }
    
    var formattedHeight: String {
        let meters = Double(height) / 10.0
        return String(format: "%.1f m", meters)
    }
    
    var formattedWeight: String {
        let kilograms = Double(weight) / 10.0
        return String(format: "%.1f kg", kilograms)
    }
}

struct Sprites: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonType: Codable {
    let type: TypeInfo
}

struct TypeInfo: Codable {
    let name: String
}

struct Stat: Codable {
    let baseStat: Int
    let stat: StatInfo
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct StatInfo: Codable {
    let name: String
}