import SwiftUI

@main
struct ScanSainApp: App {
    // Service partagé : la base d'ingrédients chassés, disponible dans toute l'app.
    @State private var watchlist = WatchlistService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(watchlist)
                .task {
                    // Au lancement, tenter de récupérer la dernière version sur GitHub.
                    await watchlist.rafraichir()
                }
        }
    }
}
