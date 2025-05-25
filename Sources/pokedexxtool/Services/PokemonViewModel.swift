import Foundation
import Observation

@Observable
@MainActor
class PokemonViewModel {
    private let pokemonService = PokemonService()
    
    // Pokemon list state
    var pokemonList: [PokemonListItem] = []
    var isListLoading = false
    var listErrorMessage: String?
    
    // Cache for individual Pokemon details
    private var pokemonCache: [Int: Pokemon] = [:]
    private var loadingPokemon: Set<Int> = []
    
    // Computed property to check if list is loaded
    var isListLoaded: Bool {
        !pokemonList.isEmpty
    }
    
    // Load the Pokemon list (only if not already loaded)
    func loadPokemonListIfNeeded() async {
        guard !isListLoaded && !isListLoading else { return }
        
        isListLoading = true
        listErrorMessage = nil
        
        do {
            pokemonList = try await pokemonService.fetchPokemonList()
        } catch {
            listErrorMessage = error.localizedDescription
        }
        
        isListLoading = false
    }
    
    // Force reload the Pokemon list
    func reloadPokemonList() async {
        pokemonList = []
        await loadPokemonListIfNeeded()
    }
    
    // Get cached Pokemon or fetch if not available
    func getPokemon(id: Int) -> Pokemon? {
        return pokemonCache[id]
    }
    
    // Load individual Pokemon details with caching
    func loadPokemon(id: Int) async throws -> Pokemon {
        // Return cached version if available
        if let cachedPokemon = pokemonCache[id] {
            return cachedPokemon
        }
        
        // Prevent multiple simultaneous requests for the same Pokemon
        guard !loadingPokemon.contains(id) else {
            // Wait for existing request to complete
            while loadingPokemon.contains(id) {
                try await Task.sleep(for: .milliseconds(50))
            }
            if let cachedPokemon = pokemonCache[id] {
                return cachedPokemon
            } else {
                return try await pokemonService.fetchPokemon(id: id)
            }
        }
        
        loadingPokemon.insert(id)
        
        do {
            let pokemon = try await pokemonService.fetchPokemon(id: id)
            pokemonCache[id] = pokemon
            loadingPokemon.remove(id)
            return pokemon
        } catch {
            loadingPokemon.remove(id)
            throw error
        }
    }
    
    // Clear cache if needed (for memory management)
    func clearCache() {
        pokemonCache.removeAll()
    }
}