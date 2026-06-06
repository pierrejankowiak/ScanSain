import Foundation

/// Une détection : un ingrédient surveillé a été repéré dans un produit.
struct Finding: Identifiable, Hashable {
    let id = UUID()
    let ingredientNom: String      // Nom de l'ingrédient chassé
    let criticite: Criticite
    let motif: String              // Pourquoi c'est signalé
    let preuve: String             // Ce qui a déclenché la détection (terme trouvé, tag…)
    let source: Source

    enum Source: String {
        case ingredients = "Liste d'ingrédients"
        case allergenes = "Allergènes / traces déclarés"
        case additifs = "Additifs déclarés"
        case toleree = "Forme tolérée"
    }
}

/// Résultat complet d'un scan, prêt à être affiché.
struct ScanResult {
    let codeBarres: String
    let produit: OFFProduct?
    let findings: [Finding]

    /// Verdict global : la pire criticité parmi les détections.
    /// Si le produit n'a pas de liste d'ingrédients exploitable, on reste « indéterminé ».
    var verdict: Criticite {
        let alertes = findings.filter { $0.criticite > .vert }
        if let pire = alertes.map(\.criticite).max() {
            return pire
        }
        // Aucune alerte : vert seulement si on a vraiment pu lire les ingrédients.
        if produit?.texteIngredients != nil { return .vert }
        return .inconnu
    }

    /// Message d'en-tête adapté au verdict.
    var resume: String {
        switch verdict {
        case .rouge:   return "Ingrédient(s) à éviter détecté(s)"
        case .orange:  return "Ingrédient(s) suspect(s) : à vérifier"
        case .jaune:   return "Additif(s) à surveiller"
        case .vert:    return "Rien de suspect détecté"
        case .inconnu: return "Données insuffisantes"
        }
    }

    /// Détections de niveau alerte (jaune et plus), triées du plus grave au moins grave.
    var alertes: [Finding] {
        findings.filter { $0.criticite > .vert }
                .sorted { $0.criticite > $1.criticite }
    }

    /// Formes tolérées repérées (vert), affichées à titre informatif.
    var tolerees: [Finding] {
        findings.filter { $0.source == .toleree }
    }
}
