import Foundation

/// Un ingrédient « chassé » de votre base.
///
/// C'est cette structure qui est décrite dans `watchlist.json` (local et distant).
/// Chaque entrée dit *quoi* chercher, *pourquoi* on le chasse et *à quel point* c'est grave,
/// avec d'éventuelles exceptions (formes tolérées).
struct WatchedIngredient: Codable, Identifiable, Hashable {
    /// Identifiant stable (ex. "amidon-modifie"). Sert de clé, ne pas le changer entre versions.
    let id: String

    /// Nom affiché à l'utilisateur (ex. "Amidon modifié").
    let nom: String

    /// Niveau de criticité par défaut quand cet ingrédient est détecté.
    let criticite: Criticite

    /// Explication : pourquoi on chasse cet ingrédient. Affichée dans le résultat et la base.
    let motif: String

    /// Termes à chercher dans la liste d'ingrédients du produit (insensible casse/accents).
    /// Ex. ["amidon modifié", "amidon transformé", "modified starch"].
    let aliases: [String]

    /// Tags d'additifs Open Food Facts à repérer, sans le préfixe "en:" (ex. ["e471"]).
    let additifsTags: [String]

    /// Tags d'allergènes/traces Open Food Facts à repérer, sans "en:" (ex. ["gluten"]).
    let allergenesTags: [String]

    /// Formes tolérées qui font baisser (ou annulent) l'alerte.
    /// Ex. pour l'amidon modifié : "amidon modifié de maïs" → toléré (vert).
    let exceptions: [Exception]

    struct Exception: Codable, Hashable {
        let aliases: [String]
        let criticite: Criticite
        let motif: String
    }

    // Valeurs par défaut pour que le JSON puisse omettre les champs vides.
    enum CodingKeys: String, CodingKey {
        case id, nom, criticite, motif, aliases, exceptions
        case additifsTags = "additifs_tags"
        case allergenesTags = "allergenes_tags"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        nom = try c.decode(String.self, forKey: .nom)
        criticite = try c.decode(Criticite.self, forKey: .criticite)
        motif = try c.decode(String.self, forKey: .motif)
        aliases = try c.decodeIfPresent([String].self, forKey: .aliases) ?? []
        additifsTags = try c.decodeIfPresent([String].self, forKey: .additifsTags) ?? []
        allergenesTags = try c.decodeIfPresent([String].self, forKey: .allergenesTags) ?? []
        exceptions = try c.decodeIfPresent([Exception].self, forKey: .exceptions) ?? []
    }
}

/// Métadonnées + liste, racine du fichier `watchlist.json`.
struct Watchlist: Codable {
    let version: Int
    let miseAJour: String
    let ingredients: [WatchedIngredient]

    enum CodingKeys: String, CodingKey {
        case version
        case miseAJour = "mise_a_jour"
        case ingredients
    }
}
