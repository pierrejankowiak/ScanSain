# Fiche App Store ScanVad

Tout ce qui est à recopier dans **App Store Connect**. Les champs ont des limites de
caractères indiquées entre parenthèses.

## Identité

- **Nom de l'app** (30 max) : `ScanVad`
  - Si « ScanVad » est déjà pris, replis possibles : `ScanVad - sans gluten`, `ScanVad: gluten`.
- **Sous-titre** (30 max) : `Gluten et additifs au scan`
- **Catégorie principale** : Santé et remise en forme
- **Catégorie secondaire** (optionnelle) : Alimentation et boissons
- **Langue principale** : Français
- **Bundle ID** : `fr.jankowiak.scansain`
- **Copyright** : `2026 Pierre Jankowiak`

## Texte promotionnel (170 max, modifiable sans nouvelle revue)

> Scannez un produit, repérez en un clin d'œil le gluten (même caché) et les additifs à
> surveiller. Gratuit, sans publicité, open source.

## Description

> ScanVad aide les personnes cœliaques, intolérantes ou simplement vigilantes à repérer
> rapidement les ingrédients indésirables d'un produit alimentaire.
>
> Scannez le code-barres : l'application interroge la base publique Open Food Facts, croise
> les ingrédients avec une liste de surveillance, et affiche un verdict clair par niveau de
> criticité, avec une explication pour chaque ingrédient signalé.
>
> CE QUE FAIT SCANVAD
> • Détecte le gluten déclaré ET ses formes cachées (amidon modifié non précisé, malt,
>   protéines végétales hydrolysées, sauce soja…).
> • Signale des additifs à surveiller (E471, nitrites, dioxyde de titane E171…).
> • Gère les exceptions : « amidon de maïs », « avoine sans gluten » ou « blé noir » (sarrasin)
>   ne déclenchent pas d'alerte.
> • Explique POURQUOI chaque ingrédient est signalé.
> • Fonctionne avec une liste de surveillance mise à jour à distance.
>
> NIVEAUX DE CRITICITÉ
> • Rouge : à éviter (gluten avéré).
> • Orange : suspect, dépend de la recette.
> • Jaune : additif à surveiller.
> • Vert : rien de suspect détecté.
>
> GRATUITE ET RESPECTUEUSE
> Aucune publicité, aucun compte, aucune collecte de données, code source ouvert.
>
> IMPORTANT
> ScanVad est une aide à la lecture des étiquettes, pas un dispositif médical ni une garantie.
> Les données Open Food Facts sont communautaires et les recettes évoluent : vérifiez toujours
> l'étiquette du produit. En cas de doute, demandez conseil à un professionnel de santé.
>
> Données produits fournies par Open Food Facts (licence ODbL).

## Mots-clés (100 caractères max, séparés par des virgules)

`gluten,sans gluten,coeliaque,cœliaque,intolérance,additifs,E471,allergènes,code-barres,régime`

## URL

- **URL d'assistance** : `https://github.com/pierrejankowiak/ScanSain`
- **URL marketing** (optionnelle) : `https://github.com/pierrejankowiak/ScanSain`
- **Politique de confidentialité** : `https://pierrejankowiak.github.io/ScanSain/privacy.html`
  (à activer : dépôt GitHub → Settings → Pages → Source = branche `main`, dossier `/docs`)

## Confidentialité de l'app (« App Privacy »)

Répondre dans App Store Connect : **« Les données ne sont pas collectées »**
(No data collected). L'app n'utilise ni publicité, ni analytics, ni compte, ni tracking.

## Classification par âge

Aucun contenu sensible → classification **4+**.

## Notes pour l'examinateur Apple (Review Notes)

> L'application ne nécessite aucun compte. Le scan de code-barres requiert un appareil avec
> caméra ; sur simulateur, un champ de saisie manuelle permet de tester. Exemples de
> codes-barres :
> • 3017620422003 (produit sans gluten → verdict vert)
> • un paquet de pâtes ou de biscuits au blé → verdict rouge (gluten)
> ScanVad est une aide à la lecture d'étiquettes, pas un dispositif médical ; des avertissements
> en ce sens sont présents dans l'app (écran de résultat et page « À propos »).

## Captures d'écran (obligatoires)

Au moins un jeu pour iPhone 6,9" (ou 6,5"). Le plus simple et le plus authentique :
les prendre directement sur ton iPhone (bouton latéral + volume haut). Écrans conseillés :
1. Un résultat **rouge** (scan de pâtes au blé).
2. Un résultat **vert** (produit sans gluten).
3. La liste **Ingrédients chassés**.
4. Le détail d'un ingrédient (le « pourquoi »).
5. La page **À propos**.
