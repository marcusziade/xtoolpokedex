import SwiftUI

struct PokemonListView: View {
    @State private var viewModel = PokemonViewModel()
    @State private var scrollPosition: Int?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isListLoading {
                    ProgressView("Loading Pokédex...")
                } else if let errorMessage = viewModel.listErrorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error: \(errorMessage)")
                        Button("Retry") {
                            Task {
                                await viewModel.reloadPokemonList()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.pokemonList) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemon.pokemonId, viewModel: viewModel)) {
                            PokemonRowView(pokemon: pokemon)
                        }
                        .id(pokemon.pokemonId)
                    }
                    .scrollPosition(id: $scrollPosition)
                }
            }
            .navigationTitle("Pokédex (Gen 1-2)")
            .task {
                await viewModel.loadPokemonListIfNeeded()
            }
        }
    }
}

struct PokemonRowView: View {
    let pokemon: PokemonListItem
    
    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.pokemonId).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ShimmerView()
                    .cornerRadius(8)
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