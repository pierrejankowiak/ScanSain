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
        let sansGluten = produit.estEtiquetteSansGluten

        for ingredient in watchlist {
            // Un ingrédient « lié au gluten » est celui qui surveille l'allergène gluten.
            let lieAuGluten = ingredient.allergenesTags.contains { $0.lowercased() == "gluten" }

            // 1) Allergènes / traces déclarés par le fabricant (signal fort et structuré).
            for tag in ingredient.allergenesTags where allergenes.contains(tag.lowercased()) {
                findings.append(Finding(
                    ingredientNom: ingredient.nom,
                    criticite: ingredient.criticite,
                    motif: ingredient.motif,
                    preuve: "Allergène/trace déclaré : « \(tag) »",
                    source: .allergenes
                ))
            }

            // 2) Additifs déclarés (E-numbers, donnée structurée).
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
                        texte = texte.replacingOccurrences(of: n, with: " ")
                    }
                }
            }

            // 3b) Garde-fou : si le produit est étiqueté « sans gluten » par OFF,
            //     on ne cherche pas le gluten dans le texte (évite les faux positifs
            //     du type "amidon de blé" rendu sans gluten, ou mentions parasites).
            if sansGluten && lieAuGluten {
                continue
            }

            // 3c) Chercher les aliases de base dans le texte restant, en ignorant
            //     les mentions NIÉES ("sans gluten", "gluten free", etc.).
            for alias in ingredient.aliases {
                let n = TextNormalizer.normalize(alias)
                let texteSansNegation = TextNormalizer.retirerNegations(texte, terme: n)
                if TextNormalizer.contains(texteSansNegation, term: n) {
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

        return ScanResult(codeBarres: codeBarres, produit: produit,
                          findings: dedoublonner(findings))
    }

    /// Garde une seule détection d'alerte par ingrédient (la plus fiable et la plus
    /// critique), et conserve les formes tolérées. Évite par ex. d'afficher E471
    /// deux fois (additif déclaré ET texte).
    private static func dedoublonner(_ findings: [Finding]) -> [Finding] {
        let priorite: [Finding.Source: Int] = [
            .allergenes: 3, .additifs: 2, .ingredients: 1, .toleree: 0
        ]
        var meilleureAlerte: [String: Finding] = [:]
        var tolerees: [Finding] = []

        for f in findings {
            if f.source == .toleree {
                tolerees.append(f)
                continue
            }
            if let actuel = meilleureAlerte[f.ingredientNom] {
                let plusCritique = f.criticite > actuel.criticite
                let memeCriticiteMeilleureSource = f.criticite == actuel.criticite
                    && (priorite[f.source] ?? 0) > (priorite[actuel.source] ?? 0)
                if plusCritique || memeCriticiteMeilleureSource {
                    meilleureAlerte[f.ingredientNom] = f
                }
            } else {
                meilleureAlerte[f.ingredientNom] = f
            }
        }

        // Dédoublonner aussi les formes tolérées (même ingrédient + même preuve).
        var vues = Set<String>()
        let tolereesUniques = tolerees.filter { vues.insert($0.ingredientNom + "|" + $0.preuve).inserted }

        return Array(meilleureAlerte.values) + tolereesUniques
    }
}
