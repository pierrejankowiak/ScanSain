import SwiftUI

/// Consultation de la base d'ingrédients chassés (lecture seule dans l'app).
/// La mise à jour se fait en éditant le fichier `watchlist.json` sur GitHub.
struct WatchlistView: View {
    @Environment(WatchlistService.self) private var watchlist
    @State private var recherche = ""

    private var resultats: [WatchedIngredient] {
        guard !recherche.isEmpty else { return watchlist.ingredients }
        let q = TextNormalizer.normalize(recherche)
        return watchlist.ingredients.filter { ing in
            TextNormalizer.normalize(ing.nom).contains(q)
            || ing.aliases.contains { TextNormalizer.normalize($0).contains(q) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(resultats) { ingredient in
                        NavigationLink {
                            IngredientDetailView(ingredient: ingredient)
                        } label: {
                            HStack {
                                Image(systemName: ingredient.criticite.symbole)
                                    .foregroundStyle(ingredient.criticite.couleur)
                                Text(ingredient.nom)
                                Spacer()
                                Text(ingredient.criticite.libelle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } footer: {
                    Text("Base v\(watchlist.version) • \(watchlist.miseAJour) • source : \(watchlist.origine)")
                }
            }
            .searchable(text: $recherche, prompt: "Rechercher un ingrédient")
            .navigationTitle("Ingrédients chassés")
            .refreshable { await watchlist.rafraichir() }
            .overlay {
                if watchlist.ingredients.isEmpty {
                    ContentUnavailableView("Base vide",
                        systemImage: "tray",
                        description: Text("Tirez vers le bas pour télécharger la liste."))
                }
            }
        }
    }
}

/// Détail d'un ingrédient chassé : motif, formes recherchées et exceptions.
struct IngredientDetailView: View {
    let ingredient: WatchedIngredient

    var body: some View {
        List {
            Section {
                CriticiteBadge(criticite: ingredient.criticite, grand: true)
                Text(ingredient.motif)
            } header: {
                Text("Pourquoi on le surveille")
            }

            if !ingredient.aliases.isEmpty {
                Section("Termes recherchés") {
                    ForEach(ingredient.aliases, id: \.self) { Text($0) }
                }
            }

            if !ingredient.additifsTags.isEmpty {
                Section("Additifs (E-numbers)") {
                    ForEach(ingredient.additifsTags, id: \.self) { Text($0.uppercased()) }
                }
            }

            if !ingredient.allergenesTags.isEmpty {
                Section("Allergènes / traces") {
                    ForEach(ingredient.allergenesTags, id: \.self) { Text($0) }
                }
            }

            if !ingredient.exceptions.isEmpty {
                Section("Formes tolérées") {
                    ForEach(ingredient.exceptions, id: \.self) { ex in
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(ex.aliases, id: \.self) {
                                Text($0).font(.subheadline.weight(.medium))
                            }
                            Text(ex.motif)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle(ingredient.nom)
        .navigationBarTitleDisplayMode(.inline)
    }
}
