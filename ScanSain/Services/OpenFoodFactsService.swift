import Foundation

/// Interroge l'API publique Open Food Facts par code-barres.
enum OpenFoodFactsService {

    enum ServiceError: LocalizedError {
        case produitIntrouvable
        case reseau(String)

        var errorDescription: String? {
            switch self {
            case .produitIntrouvable:
                return "Produit inconnu d'Open Food Facts. Vous pouvez l'ajouter sur openfoodfacts.org."
            case .reseau(let msg):
                return "Problème de connexion : \(msg)"
            }
        }
    }

    /// Champs demandés à l'API (limiter la taille de la réponse).
    private static let champs = [
        "product_name", "product_name_fr", "brands",
        "ingredients_text", "ingredients_text_fr",
        "allergens_tags", "traces_tags", "additives_tags",
        "image_front_small_url"
    ].joined(separator: ",")

    static func recupererProduit(codeBarres: String) async throws -> OFFProduct {
        let code = codeBarres.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string:
            "https://world.openfoodfacts.org/api/v2/product/\(code).json") else {
            throw ServiceError.reseau("URL invalide")
        }
        components.queryItems = [URLQueryItem(name: "fields", value: champs)]
        guard let url = components.url else {
            throw ServiceError.reseau("URL invalide")
        }

        var request = URLRequest(url: url)
        // Open Food Facts demande un User-Agent identifiant l'application.
        request.setValue("ScanVad/1.0 (open source; github.com/pierrejankowiak/ScanSain)",
                         forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 404 {
                throw ServiceError.produitIntrouvable
            }
            let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
            guard decoded.status == 1, let produit = decoded.product else {
                throw ServiceError.produitIntrouvable
            }
            return produit
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.reseau(error.localizedDescription)
        }
    }
}
