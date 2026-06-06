import Foundation
import Observation

/// Gère la base d'ingrédients chassés.
///
/// Priorité de chargement :
///   1. Fichier distant sur GitHub (mise à jour sans repasser par l'App Store) ;
///   2. Cache disque du dernier téléchargement réussi ;
///   3. Copie embarquée dans l'app (toujours présente, garantit un fonctionnement hors-ligne).
@Observable
@MainActor
final class WatchlistService {

    /// URL « raw » du fichier JSON sur le dépôt GitHub.
    static let urlDistante = URL(string:
        "https://raw.githubusercontent.com/pierrejankowiak/ScanSain/main/data/watchlist.json")

    private(set) var ingredients: [WatchedIngredient] = []
    private(set) var version: Int = 0
    private(set) var miseAJour: String = ""
    private(set) var origine: String = "embarquée"

    private var fichierCache: URL {
        let dossier = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dossier.appendingPathComponent("watchlist.json")
    }

    init() {
        chargerLocal()
    }

    /// Charge la meilleure version locale disponible (cache puis embarquée).
    func chargerLocal() {
        if let data = try? Data(contentsOf: fichierCache),
           let liste = try? decoder.decode(Watchlist.self, from: data) {
            appliquer(liste, origine: "cache")
            return
        }
        chargerEmbarquee()
    }

    private func chargerEmbarquee() {
        guard let url = Bundle.main.url(forResource: "watchlist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let liste = try? decoder.decode(Watchlist.self, from: data) else {
            return
        }
        appliquer(liste, origine: "embarquée")
    }

    /// Télécharge la version distante si disponible, sinon garde la version locale.
    func rafraichir() async {
        guard let url = Self.urlDistante else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let liste = try decoder.decode(Watchlist.self, from: data)
            // On n'écrase que si la version distante est au moins aussi récente.
            if liste.version >= version {
                try? data.write(to: fichierCache)
                appliquer(liste, origine: "à jour (GitHub)")
            }
        } catch {
            // Hors-ligne ou URL non configurée : on conserve la version locale.
        }
    }

    private func appliquer(_ liste: Watchlist, origine: String) {
        self.ingredients = liste.ingredients
        self.version = liste.version
        self.miseAJour = liste.miseAJour
        self.origine = origine
    }

    private var decoder: JSONDecoder { JSONDecoder() }
}
