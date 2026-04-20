# TP Flutter - Star Wars Explorer

Application Flutter realisee dans le cadre d'un TP pour explorer l'univers Star Wars via l'API `swapi.tech`.

## Objectif du TP

L'objectif est de construire une application mobile avec :

- une navigation entre plusieurs ecrans ;
- la consommation d'une API REST ;
- l'affichage de listes et grilles dynamiques ;
- une interface personnalisee sur un theme commun (style galaxie / Star Wars).

## Fonctionnalites

- Navigation par barre inferieure entre 3 sections :
  - `Films`
  - `Planetes`
  - `Heros`
- Recuperation des donnees depuis l'API Star Wars (`swapi.tech`) avec le package `http`.
- Ecran `Films` :
  - affichage des episodes tries par numero ;
  - carte detaillee avec titre, date de sortie, realisateur et extrait du opening crawl.
- Ecran `Planetes` :
  - affichage en grille de planetes ;
  - informations principales (climat, terrain, population, surface d'eau).
- Ecran `Heros` :
  - liste des personnages ;
  - affichage de statistiques (taille, poids, couleur des yeux, etc.).
- Gestion des etats de chargement et d'erreur :
  - indicateur de chargement pendant les appels reseau ;
  - message explicite en cas d'echec API / connexion.
- Theme visuel personnalise :
  - fond etoile global ;
  - couleurs, badges et cartes adaptes a chaque type de contenu.

## Difficultes rencontrees

- **Recuperation des donnees detaillees** : certaines routes API renvoient une liste minimale puis necessitent un second appel pour chaque element (ex: personnages et planetes).
- **Gestion asynchrone** : il fallait bien enchaîner les appels HTTP et mettre a jour l'interface au bon moment sans bloquer l'application.
- **Gestion des erreurs reseau** : traiter les cas d'echec de connexion ou de reponse non valide pour eviter les crashes.
- **Homogeneite visuelle** : conserver une identite graphique unique sur des ecrans differents (liste, grille, cartes).
- **Images externes** : prevoir un fallback visuel quand une image distante ne se charge pas.

## Technologies utilisees

- Flutter
- Dart
- Package `http`
- API Star Wars : [https://swapi.tech](https://swapi.tech)

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Structure principale

- `lib/main.dart` : theme global, fond etoile, navigation principale.
- `lib/screens/films_screen.dart` : ecran des films.
- `lib/screens/planet_screen.dart` : ecran des planetes.
- `lib/screens/characters_screen.dart` : ecran des heros.

---

Projet realise dans un cadre pedagogique (TP Flutter).
