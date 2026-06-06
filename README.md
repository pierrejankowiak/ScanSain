# ScanSain

Application iOS **gratuite, sans publicité et open source** qui scanne le code-barres d'un produit
alimentaire, interroge la base publique [Open Food Facts](https://world.openfoodfacts.org), croise
les ingrédients avec une liste de surveillance personnelle et affiche un **verdict par niveau de
criticité** (à éviter / suspect / à surveiller / rien détecté), avec une explication pour chaque
ingrédient signalé.

Conçue au départ pour aider un enfant atteint de **maladie cœliaque** (détection du gluten déclaré
*et* caché), elle gère aussi des additifs surveillés (E471, nitrites, dioxyde de titane E171, etc.).

> ⚠️ **Ce n'est pas un dispositif médical.** Le résultat est une aide, pas une garantie : les données
> Open Food Facts sont communautaires et les recettes changent. **Vérifiez toujours l'étiquette.**

## Comment ça marche

1. Scan du code-barres (caméra, via le framework Vision d'Apple).
2. Appel de l'API Open Food Facts pour récupérer ingrédients, allergènes, traces et additifs.
3. Croisement avec la liste de surveillance (`watchlist.json`).
4. Verdict coloré + détail des détections et de leurs motifs.

## Niveaux de criticité

| Niveau | Sens | Exemple |
|--------|------|---------|
| 🔴 Rouge | Présence avérée d'un ingrédient interdit | Gluten déclaré |
| 🟠 Orange | Suspect, dépend de la recette | « Amidon modifié » sans origine précisée |
| 🟡 Jaune | Additif à surveiller | E471 |
| 🟢 Vert | Rien de suspect (ou forme tolérée) | « Amidon **de maïs** » |
| ⚪️ Indéterminé | Données insuffisantes | Produit sans liste d'ingrédients |

## La base d'ingrédients (`watchlist.json`)

La liste surveillée vit dans [`data/watchlist.json`](data/watchlist.json). Chaque entrée :

```json
{
  "id": "amidon-modifie",
  "nom": "Amidon modifié / amidon non précisé",
  "criticite": "orange",
  "motif": "Un amidon « modifié » sans céréale précisée peut provenir du blé…",
  "aliases": ["amidon modifié", "amidon transformé", "amidon", "fécule"],
  "additifs_tags": [],
  "allergenes_tags": [],
  "exceptions": [
    {
      "aliases": ["amidon de maïs", "fécule de pomme de terre"],
      "criticite": "vert",
      "motif": "Maïs et pomme de terre ne contiennent pas de gluten."
    }
  ]
}
```

- `criticite` : `rouge`, `orange`, `jaune` ou `vert`.
- `aliases` : termes cherchés dans la liste d'ingrédients (accents/casse ignorés).
- `additifs_tags` : E-numbers Open Food Facts, en minuscules sans préfixe (`e471`).
- `allergenes_tags` : allergènes/traces Open Food Facts (`gluten`).
- `exceptions` : formes plus précises qui font baisser l'alerte (le moteur les retire du texte
  avant de chercher la forme générale, donc « amidon de maïs » n'est jamais compté comme suspect).

### Mettre à jour la base sans repasser par l'App Store

L'app télécharge `watchlist.json` depuis votre dépôt GitHub à chaque lancement, garde une copie en
cache, et embarque une copie de secours pour fonctionner hors-ligne.

1. Modifiez `data/watchlist.json`, **incrémentez `version`** et mettez à jour `mise_a_jour`.
2. `git commit` + `git push`.
3. Renseignez l'URL « raw » de votre fichier dans
   [`ScanSain/Services/WatchlistService.swift`](ScanSain/Services/WatchlistService.swift) (`urlDistante`).

> Pensez à garder `ScanSain/Resources/watchlist.json` (copie embarquée) synchronisé de temps en
> temps avec `data/watchlist.json`.

## Lancer le projet (débutant)

1. **Installer Xcode** depuis le Mac App Store (gratuit).
2. Double-cliquer **`ScanSain.xcodeproj`**.
3. En haut, choisir un simulateur iPhone (ou votre iPhone branché) puis appuyer sur **▶︎ (Run)**.
   - Sur **simulateur** : pas de caméra → utilisez le champ de **saisie manuelle** d'un code-barres
     (essayez `3017620422003`, une pâte à tartiner connue).
   - Sur **iPhone réel** : le scan caméra fonctionne. Il faudra autoriser la caméra au 1er lancement.

## Pile technique

- **SwiftUI** (iOS 17+), **Observation** (`@Observable`).
- **VisionKit** (`DataScannerViewController`) pour le scan, sans SDK tiers.
- **Open Food Facts API v2** (licence des données : ODbL).

## Licence

Code sous licence **MIT** (voir [`LICENSE`](LICENSE)). Les données produits proviennent d'Open Food
Facts, sous licence ODbL.
