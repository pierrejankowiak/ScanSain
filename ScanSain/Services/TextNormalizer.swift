import Foundation

/// Normalise les chaînes pour une comparaison robuste :
/// minuscules, sans accents, ponctuation simplifiée, E-numbers homogénéisés.
enum TextNormalizer {

    /// "Amidon modifié de Maïs (E-1442)" -> "amidon modifie de mais (e1442)"
    static func normalize(_ input: String) -> String {
        // 1. Minuscules + suppression des accents/diacritiques.
        var s = input.folding(options: [.diacriticInsensitive, .caseInsensitive],
                              locale: Locale(identifier: "fr_FR"))
        s = s.lowercased()

        // 2. Homogénéiser les E-numbers : "e 471", "e-471", "e471" -> "e471".
        //    On colle un "e" suivi d'espaces/tirets à ses chiffres.
        s = s.replacingOccurrences(
            of: #"\be[\s\-]?(\d{3,4}[a-z]?)"#,
            with: "e$1",
            options: .regularExpression
        )

        // 3. Remplacer la ponctuation par des espaces (garder lettres/chiffres/espaces).
        s = s.replacingOccurrences(
            of: #"[^a-z0-9 ]"#,
            with: " ",
            options: .regularExpression
        )

        // 4. Réduire les espaces multiples.
        s = s.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )

        return s.trimmingCharacters(in: .whitespaces)
    }

    /// Vrai si `needle` apparaît dans `haystack` (les deux déjà normalisés),
    /// en respectant les limites de mots pour éviter les faux positifs
    /// (ex. "ble" ne doit pas matcher "ensemble").
    static func contains(_ haystack: String, term needle: String) -> Bool {
        guard !needle.isEmpty else { return false }
        let pattern = "\\b" + NSRegularExpression.escapedPattern(for: needle) + "\\b"
        return haystack.range(of: pattern, options: .regularExpression) != nil
    }
}
