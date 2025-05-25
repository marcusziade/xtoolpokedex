import SwiftUI

struct PokemonDetailView: View {
    let pokemonId: Int
    @StateObject private var pokemonService = PokemonService()
    @State private var pokemon: Pokemon?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Pokemon...")
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
            } else if let pokemon = pokemon {
                ScrollView {
                    VStack(spacing: 20) {
                        PokemonHeaderView(pokemon: pokemon)
                        PokemonTypesView(types: pokemon.types)
                        PokemonStatsView(stats: pokemon.stats)
                        PokemonInfoView(pokemon: pokemon)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(pokemon?.name.capitalized ?? "Pokemon")
        .navigationBarTitleDisplayMode(.large)
        .task {
            loadPokemon()
        }
    }
    
    private func loadPokemon() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                pokemon = try await pokemonService.fetchPokemon(id: pokemonId)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct PokemonHeaderView: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 200, height: 200)
            
            Text("#\(String(format: "%03d", pokemon.id))")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

struct PokemonTypesView: View {
    let types: [PokemonType]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Type")
                .font(.headline)
            
            HStack {
                ForEach(types, id: \.type.name) { pokemonType in
                    Text(pokemonType.type.name.capitalized)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(typeColor(for: pokemonType.type.name))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Spacer()
            }
        }
    }
    
    private func typeColor(for type: String) -> Color {
        switch type.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.red
        case "water": return Color.blue
        case "electric": return Color.yellow
        case "grass": return Color.green
        case "ice": return Color.cyan
        case "fighting": return Color.red.opacity(0.8)
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.blue.opacity(0.7)
        case "psychic": return Color.pink
        case "bug": return Color.green.opacity(0.7)
        case "rock": return Color.brown.opacity(0.8)
        case "ghost": return Color.purple.opacity(0.8)
        case "dragon": return Color.indigo
        case "dark": return Color.black
        case "steel": return Color.gray.opacity(0.8)
        case "fairy": return Color.pink.opacity(0.8)
        default: return Color.gray
        }
    }
}

struct PokemonStatsView: View {
    let stats: [Stat]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Base Stats")
                .font(.headline)
            
            ForEach(stats, id: \.stat.name) { stat in
                HStack {
                    Text(statDisplayName(stat.stat.name))
                        .frame(width: 100, alignment: .leading)
                    
                    Text("\(stat.baseStat)")
                        .frame(width: 40, alignment: .trailing)
                        .fontWeight(.medium)
                    
                    ProgressView(value: Double(stat.baseStat), total: 255.0)
                        .tint(statColor(for: stat.baseStat))
                }
            }
        }
    }
    
    private func statDisplayName(_ name: String) -> String {
        switch name {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "speed": return "Speed"
        default: return name.capitalized
        }
    }
    
    private func statColor(for value: Int) -> Color {
        switch value {
        case 0...49: return .red
        case 50...79: return .orange
        case 80...109: return .yellow
        case 110...139: return .green
        default: return .blue
        }
    }
}

struct PokemonInfoView: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Attributes")
                .font(.headline)
            
            HStack {
                VStack {
                    Text("Height")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(pokemon.formattedHeight)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack {
                    Text("Weight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(pokemon.formattedWeight)
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
        }
    }
}