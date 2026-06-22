import Foundation

/// Réponse de l'API Open Food Facts pour un produit.
/// Doc : https://openfoodfacts.github.io/openfoodfacts-server/api/
struct OFFResponse: Codable {
    let status: Int          // 1 = trouvé, 0 = inconnu
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let productName: String?
    let productNameFr: String?
    let brands: String?
    let ingredientsText: String?
    let ingredientsTextFr: String?
    let allergensTags: [String]?
    let tracesTags: [String]?
    let additivesTags: [String]?
    let labelsTags: [String]?
    let imageFrontSmallURL: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productNameFr = "product_name_fr"
        case brands
        case ingredientsText = "ingredients_text"
        case ingredientsTextFr = "ingredients_text_fr"
        case allergensTags = "allergens_tags"
        case tracesTags = "traces_tags"
        case additivesTags = "additives_tags"
        case labelsTags = "labels_tags"
        case imageFrontSmallURL = "image_front_small_url"
    }

    /// Meilleur nom disponible (français prioritaire).
    var nomAffiche: String {
        let fr = productNameFr?.trimmingCharacters(in: .whitespacesAndNewlines)
        let en = productName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let fr, !fr.isEmpty { return fr }
        if let en, !en.isEmpty { return en }
        return "Produit sans nom"
    }

    /// Meilleure liste d'ingrédients disponible (français prioritaire).
    var texteIngredients: String? {
        let fr = ingredientsTextFr?.trimmingCharacters(in: .whitespacesAndNewlines)
        let generic = ingredientsText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let fr, !fr.isEmpty { return fr }
        if let generic, !generic.isEmpty { return generic }
        return nil
    }

    /// Tags d'allergènes + traces réunis, sans le préfixe de langue "en:".
    var tousAllergenes: [String] {
        let tags = (allergensTags ?? []) + (tracesTags ?? [])
        return tags.map { $0.split(separator: ":").last.map(String.init) ?? $0 }
    }

    /// Tags d'additifs sans le préfixe "en:" (ex. "e471").
    var additifs: [String] {
        (additivesTags ?? []).map { $0.split(separator: ":").last.map(String.init) ?? $0 }
    }

    /// Tags de labels sans le préfixe "en:" (ex. "no-gluten", "organic").
    var labels: [String] {
        (labelsTags ?? []).map { $0.split(separator: ":").last.map(String.init) ?? $0 }
    }

    /// Vrai si le produit porte un label « sans gluten » certifié par Open Food Facts.
    /// Signal fort : on ne déclenche alors pas d'alerte gluten sur la base du texte.
    var estEtiquetteSansGluten: Bool {
        labels.contains { $0 == "no-gluten" || $0 == "gluten-free" }
    }
}
