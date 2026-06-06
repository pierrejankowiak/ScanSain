import SwiftUI

struct ScannerView: View {
    @Environment(WatchlistService.self) private var watchlist

    @State private var codeManuel = ""
    @State private var enChargement = false
    @State private var erreur: String?
    @State private var resultat: ScanResult?
    @State private var scanToken = UUID()   // change pour relancer le scan

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                zoneScan
                saisieManuelle
            }
            .navigationTitle("ScanVad")
            .navigationBarTitleDisplayMode(.inline)
            .overlay { if enChargement { chargement } }
            .alert("Oups", isPresented: Binding(
                get: { erreur != nil },
                set: { if !$0 { erreur = nil } }
            )) {
                Button("OK", role: .cancel) { erreur = nil }
            } message: {
                Text(erreur ?? "")
            }
            .sheet(item: Binding(
                get: { resultat.map(ResultatBox.init) },
                set: { if $0 == nil { resultat = nil; scanToken = UUID() } }
            )) { box in
                ProductResultView(resultat: box.resultat)
            }
        }
    }

    // MARK: - Zone caméra

    @ViewBuilder
    private var zoneScan: some View {
        if BarcodeScannerView.estDisponible {
            BarcodeScannerView { code in
                analyser(code)
            }
            .id(scanToken)
            .overlay(alignment: .bottom) {
                Text("Visez le code-barres du produit")
                    .font(.footnote)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 12)
            }
        } else {
            ContentUnavailableView {
                Label("Caméra indisponible", systemImage: "camera.metering.unknown")
            } description: {
                Text("Le scan caméra fonctionne sur un iPhone réel.\nSur simulateur, saisissez un code-barres ci-dessous pour tester.")
            }
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - Saisie manuelle

    private var saisieManuelle: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Code-barres (ex. 3017620422003)", text: $codeManuel)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("Analyser") {
                    analyser(codeManuel)
                }
                .buttonStyle(.borderedProminent)
                .disabled(codeManuel.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Text("Base d'ingrédients : v\(watchlist.version) • \(watchlist.origine)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.bar)
    }

    private var chargement: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView("Analyse en cours…")
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Analyse

    private func analyser(_ code: String) {
        let code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, !enChargement else { return }
        enChargement = true
        Task {
            defer { enChargement = false }
            do {
                let produit = try await OpenFoodFactsService.recupererProduit(codeBarres: code)
                resultat = IngredientMatcher.analyser(
                    produit: produit,
                    codeBarres: code,
                    watchlist: watchlist.ingredients
                )
                codeManuel = ""
            } catch {
                erreur = error.localizedDescription
                scanToken = UUID()  // réarmer le scan après une erreur
            }
        }
    }
}

/// Petit wrapper pour présenter `ScanResult` en `.sheet(item:)` (besoin d'Identifiable).
private struct ResultatBox: Identifiable {
    let id = UUID()
    let resultat: ScanResult
    init(_ resultat: ScanResult) { self.resultat = resultat }
}

#Preview {
    ScannerView()
        .environment(WatchlistService())
}
