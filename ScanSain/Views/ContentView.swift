import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScannerView()
                .tabItem { Label("Scanner", systemImage: "barcode.viewfinder") }

            WatchlistView()
                .tabItem { Label("Ingrédients", systemImage: "list.bullet.clipboard") }

            AboutView()
                .tabItem { Label("À propos", systemImage: "info.circle") }
        }
    }
}

#Preview {
    ContentView()
        .environment(WatchlistService())
}
