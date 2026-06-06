import SwiftUI

struct AboutView: View {
    @Environment(WatchlistService.self) private var watchlist

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("ScanVad aide à repérer rapidement, à partir du code-barres d'un produit, les ingrédients à éviter : gluten (déclaré ou caché), additifs surveillés, etc.")
                }

                Section("Comment ça marche") {
                    etape("1", "Vous scannez le code-barres.")
                    etape("2", "L'app interroge la base publique Open Food Facts.")
                    etape("3", "Les ingrédients sont croisés avec votre liste de surveillance.")
                    etape("4", "Un verdict par niveau de criticité s'affiche, avec les explications.")
                }

                Section("Niveaux de criticité") {
                    ForEach(Criticite.allCases.reversed(), id: \.self) { c in
                        HStack {
                            CriticiteBadge(criticite: c)
                            Spacer()
                        }
                    }
                }

                Section("Base d'ingrédients") {
                    LabeledContent("Version", value: "\(watchlist.version)")
                    LabeledContent("Mise à jour", value: watchlist.miseAJour)
                    LabeledContent("Source", value: watchlist.origine)
                    Button("Mettre à jour maintenant") {
                        Task { await watchlist.rafraichir() }
                    }
                }

                Section {
                    Label("Application gratuite, sans publicité, open source, offerte par Pierre Jankowiak.", systemImage: "heart")
                    Label {
                        Link("Proposer une amélioration : scanvad@jankowiak.fr",
                             destination: URL(string: "mailto:scanvad@jankowiak.fr")!)
                    } icon: {
                        Image(systemName: "envelope")
                    }
                    Label("Données produits : Open Food Facts (ODbL).", systemImage: "leaf")
                } footer: {
                    Text("Ce résultat est une aide, pas un avis médical ni une garantie. Vérifiez toujours l'étiquette. En cas de doute, demandez à un professionnel de santé.")
                }
            }
            .navigationTitle("À propos")
        }
    }

    private func etape(_ n: String, _ texte: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(n)
                .font(.headline)
                .frame(width: 26, height: 26)
                .background(Color.accentColor, in: Circle())
                .foregroundStyle(.white)
            Text(texte)
        }
    }
}

#Preview {
    AboutView()
        .environment(WatchlistService())
}
