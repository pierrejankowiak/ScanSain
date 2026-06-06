import SwiftUI

/// Affiche le verdict d'un scan : criticité globale, détections et explications.
struct ProductResultView: View {
    let resultat: ScanResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                enTete
                if !resultat.alertes.isEmpty { sectionAlertes }
                if !resultat.tolerees.isEmpty { sectionTolerees }
                sectionProduit
                sectionAvertissement
            }
            .navigationTitle("Résultat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    private var enTete: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: resultat.verdict.symbole)
                    .font(.system(size: 52))
                    .foregroundStyle(resultat.verdict.couleur)
                Text(resultat.resume)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                CriticiteBadge(criticite: resultat.verdict, grand: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private var sectionAlertes: some View {
        Section("Détections") {
            ForEach(resultat.alertes) { finding in
                FindingRow(finding: finding)
            }
        }
    }

    private var sectionTolerees: some View {
        Section("Formes précisées (a priori tolérées)") {
            ForEach(resultat.tolerees) { finding in
                FindingRow(finding: finding)
            }
        }
    }

    private var sectionProduit: some View {
        Section("Produit") {
            if let produit = resultat.produit {
                LabeledContent("Nom", value: produit.nomAffiche)
                if let marques = produit.brands, !marques.isEmpty {
                    LabeledContent("Marque", value: marques)
                }
                LabeledContent("Code-barres", value: resultat.codeBarres)
                if let texte = produit.texteIngredients {
                    DisclosureGroup("Liste d'ingrédients") {
                        Text(texte)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Open Food Facts n'a pas de liste d'ingrédients pour ce produit. Impossible de se prononcer, lisez l'étiquette.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Produit introuvable.")
            }
        }
    }

    private var sectionAvertissement: some View {
        Section {
            Label {
                Text("Ce résultat est une aide, pas une garantie. Les données Open Food Facts sont communautaires et les recettes changent. Vérifiez toujours l'étiquette du produit.")
            } icon: {
                Image(systemName: "exclamationmark.bubble")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}

/// Une ligne de détection : ingrédient, criticité, preuve et motif.
private struct FindingRow: View {
    let finding: Finding

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(finding.ingredientNom)
                    .font(.headline)
                Spacer()
                CriticiteBadge(criticite: finding.criticite)
            }
            Text(finding.preuve)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Source : \(finding.source.rawValue)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text(finding.motif)
                .font(.callout)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}
