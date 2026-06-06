import Foundation

/// Croise un produit Open Food Facts avec votre base d'ingrédients chassés
/// et produit la liste des détections.
enum IngredientMatcher {

    static func analyser(produit: OFFProduct, codeBarres: String,
                         watchlist: [WatchedIngredient]) -> ScanResult {
        var findings: [Finding] = []

        let texteNormalise = produit.texteIngredients.map(TextNormalizer.normalize)
        let additifs = Set(produit.additifs.map { $0.lowercased() })
        let allergenes = Set(produit.tousAllergenes.map { $0.lowercased() })

        for ingredient in watchlist {
            // 1) Allergènes / traces déclarés par le fabricant (signal fort).
            for tag in ingredient.allergenesTags where allergenes.contains(tag.lowercased()) {
                findings.append(Finding(
                    ingredientNom: ingredient.nom,
                    criticite: ingredient.criticite,
                    motif: ingredient.motif,
                    preuve: "Allergène/trace déclaré : « \(tag) »",
                    source: .allergenes
                ))
            }

            // 2) Additifs déclarés (E-numbers).
            for tag in ingredient.additifsTags where additifs.contains(tag.lowercased()) {
                findings.append(Finding(
                    ingredientNom: ingredient.nom,
                    criticite: ingredient.criticite,
                    motif: ingredient.motif,
                    preuve: "Additif déclaré : « \(tag.uppercased()) »",
                    source: .additifs
                ))
            }

            // 3) Analyse textuelle de la liste d'ingrédients.
            guard var texte = texteNormalise else { continue }

            // 3a) Repérer d'abord les formes tolérées, et les retirer du texte
            //     pour ne pas redéclencher l'alerte de base sur la même mention.
            //     Ex. "amidon modifié de maïs" est retiré avant de chercher "amidon modifié".
            var formeToleree = false
            for exception in ingredient.exceptions {
                for alias in exception.aliases {
                    let n = TextNormalizer.normalize(alias)
                    if TextNormalizer.contains(texte, term: n) {
                        formeToleree = true
                        findings.append(Finding(
                            ingredientNom: ingredient.nom,
                            criticite: exception.criticite,
                            motif: exception.motif,
                            preuve: "Forme précisée : « \(alias) »",
                            source: .toleree
                        ))
                        // Retirer toutes les occurrences de cette forme tolérée.
                        texte = texte.replacingOccurrences(of: n, with: " ")
                    }
                }
            }

            // 3b) Chercher les aliases de base dans le texte restant.
            for alias in ingredient.aliases {
                let n = TextNormalizer.normalize(alias)
                if TextNormalizer.contains(texte, term: n) {
                    findings.append(Finding(
                        ingredientNom: ingredient.nom,
                        criticite: ingredient.criticite,
                        motif: formeToleree
                            ? ingredient.motif + "\n\nNote : une forme précisée (tolérée) a aussi été repérée. Vérifiez bien chaque mention sur l'étiquette."
                            : ingredient.motif,
                        preuve: "Terme trouvé : « \(alias) »",
                        source: .ingredients
                    ))
                    break // un seul finding « ingrédients » par ingrédient suffit
                }
            }
        }

        return ScanResult(codeBarres: codeBarres, produit: produit, findings: findings)
    }
}
