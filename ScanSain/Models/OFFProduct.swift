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
}
