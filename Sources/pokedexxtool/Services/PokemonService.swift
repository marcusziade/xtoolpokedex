import Foundation

@MainActor
class PokemonService: ObservableObject {
    private let baseURL = "https://pokeapi.co/api/v2"
    
    func fetchPokemonList() async throws -> [PokemonListItem] {
        let url = URL(string: "\(baseURL)/pokemon?limit=251")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        return response.results
    }
    
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let url = URL(string: "\(baseURL)/pokemon/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Pokemon.self, from: data)
    }
    
    func fetchPokemon(name: String) async throws -> Pokemon {
        let url = URL(string: "\(baseURL)/pokemon/\(name.lowercased())")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Pokemon.self, from: data)
    }
}