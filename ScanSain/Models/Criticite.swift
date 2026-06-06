import SwiftUI

/// Niveau de criticité d'un résultat.
///
/// L'application ne peut jamais garantir un résultat à 100 % : les données
/// d'Open Food Facts sont communautaires et les recettes changent. La criticité
/// exprime donc un degré de confiance / de danger, pas une certitude.
enum Criticite: String, Codable, CaseIterable, Comparable {
    case inconnu   // Données insuffisantes pour se prononcer
    case vert      // Rien de suspect détecté (ou forme tolérée)
    case jaune     // Additif à surveiller (ex. E471)
    case orange    // Suspect : dépend de la recette, à vérifier sur l'étiquette
    case rouge     // Présence avérée d'un ingrédient interdit (ex. gluten déclaré)

    /// Rang utilisé pour déterminer le verdict global (le pire l'emporte).
    private var rang: Int {
        switch self {
        case .inconnu: return 0
        case .vert:    return 1
        case .jaune:   return 2
        case .orange:  return 3
        case .rouge:   return 4
        }
    }

    static func < (lhs: Criticite, rhs: Criticite) -> Bool {
        lhs.rang < rhs.rang
    }

    var libelle: String {
        switch self {
        case .inconnu: return "Indéterminé"
        case .vert:    return "Rien détecté"
        case .jaune:   return "À surveiller"
        case .orange:  return "Suspect"
        case .rouge:   return "À éviter"
        }
    }

    var couleur: Color {
        switch self {
        case .inconnu: return .gray
        case .vert:    return .green
        case .jaune:   return .yellow
        case .orange:  return .orange
        case .rouge:   return .red
        }
    }

    var symbole: String {
        switch self {
        case .inconnu: return "questionmark.circle.fill"
        case .vert:    return "checkmark.circle.fill"
        case .jaune:   return "exclamationmark.circle.fill"
        case .orange:  return "exclamationmark.triangle.fill"
        case .rouge:   return "xmark.octagon.fill"
        }
    }
}
