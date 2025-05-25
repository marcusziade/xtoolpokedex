import SwiftUI

struct PokemonListView: View {
    @StateObject private var pokemonService = PokemonService()
    @State private var pokemonList: [PokemonListItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Pokédex...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error: \(errorMessage)")
                        Button("Retry") {
                            loadPokemon()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(pokemonList) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemon.pokemonId)) {
                            PokemonRowView(pokemon: pokemon)
                        }
                    }
                }
            }
            .navigationTitle("Pokédex (Gen 1-2)")
            .task {
                loadPokemon()
            }
        }
    }
    
    private func loadPokemon() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                pokemonList = try await pokemonService.fetchPokemonList()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct PokemonRowView: View {
    let pokemon: PokemonListItem
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.pokemonId).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading) {
                Text("#\(String(format: "%03d", pokemon.pokemonId))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(pokemon.name.capitalized)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}