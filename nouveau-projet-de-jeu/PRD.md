# Product Requirements Document — SurfGame

**Version :** 1.0  
**Date :** Avril 2026  
**Moteur :** Godot 4 (GDScript)  
**Plateforme cible :** Mobile (Android/iOS) — compatible bureau (Windows/Mac/Linux)

---

## 1. Pourquoi ce projet existe

SurfGame est un jeu mobile de surf en vue 2D latérale conçu pour offrir des sessions courtes et addictives, sans connexion internet ni fichiers de ressources externes. Il résout le manque de jeu de surf accessible, pick-up-and-play, avec une boucle de progression claire (score, XP, déblocage de cosmétiques) qui donne envie de rejouer. Tous les visuels sont dessinés procéduralement — aucun asset graphique externe n'est nécessaire, ce qui rend le projet entièrement autonome et léger.

---

## 2. Ce que fait l'application (périmètre fonctionnel)

### 2.1 Boucle de jeu principale
- Le joueur contrôle un surfeur qui se déplace librement dans la zone d'eau (2D, vue côté).
- Des obstacles apparaissent en continu depuis la droite : **requins** et **méduses**, chacun avec vitesse, amplitude de balancement et phase aléatoires.
- Des **SurfCoins** apparaissent régulièrement et peuvent être collectés en les touchant avec le surfeur ou la planche.
- Des **étoiles boost** apparaissent toutes les 9–16 secondes. Les collecter active un boost de 8 secondes : invincibilité aux obstacles + XP 20× plus rapide.
- Le surfeur peut exécuter un **backflip** (figure) : saut parabolique + rotation complète, +250 points et +5 XP, cooldown 0,6 s.
- La **difficulté augmente progressivement** : vitesse des obstacles, fréquence d'apparition, et vitesse du surfeur croissent lentement sur 30 minutes.
- Le **score** s'incrémente en continu (×1 + facteur difficulté). Il est affiché en temps réel dans le HUD.
- La partie se termine au contact d'un obstacle (sauf boost actif).

### 2.2 Système de progression persistante
- **XP** : gagné passivement toutes les 10 s (×20 en boost). Débloque visuellement la maison du menu principal (cabane → grande maison à 200 XP → château à 500 XP).
- **SurfCoins** : collectés en jeu, utilisés comme monnaie en boutique. Persistés entre les sessions.
- **High Score** : meilleur score toutes parties confondues, sauvegardé localement.
- Toutes les données sont sauvegardées au format JSON dans `user://save.json`.

### 2.3 Profil joueur
- Le joueur crée un profil avec un **pseudo** et choisit son **personnage de départ**.
- Le profil est modifiable à tout moment depuis la page Profil.
- Affichage du pseudo, du personnage équipé, du total XP et du total SurfCoins.

### 2.4 Boutique
- Catalogue de **4 combinaisons** et **5 planches de surf**, avec prix en SurfCoins.
- Items gratuits débloqués d'office (Surfeur Classique, Planche Classique).
- Achat avec débit immédiat du solde. Achat impossible si solde insuffisant.
- Après achat, l'item est immédiatement disponible dans le dressing.

### 2.5 Dressing
- Affiche uniquement les items **possédés** par le joueur (achetés ou gratuits).
- Permet d'équiper un personnage ou une planche d'un seul appui.
- Mis à jour automatiquement à chaque ouverture après un achat en boutique.

### 2.6 Paramètres
- Volume musique (0–100 %)
- Volume effets sonores (0–100 %)
- Bouton Sourdine global
- Sensibilité des contrôles (20–150 %)
- Activation/désactivation des vibrations
- Réinitialisation complète de la progression (double-confirmation requise)

### 2.7 Effets sonores
- Tous les sons sont **générés procéduralement** via `AudioStreamGenerator` (GDScript pur).
- 4 sons : collecte de pièce, collecte d'étoile, mort, figure.

---

## 3. Comment l'utilisateur interagit avec l'application

### 3.1 Navigation entre écrans

```
Menu Principal
├── [Jouer]         → GameLevel (partie)
├── [Boutique]      → ShopDressing (onglet Boutique ouvert)
├── [Dressing]      → ShopDressing (onglet Dressing ouvert)
├── [Profil]        → ProfilePage
├── [Paramètres]    → SettingsPage
└── [Clic surfeur]  → Lance une partie directement
```

### 3.2 Contrôles en jeu

| Plateforme | Action              | Contrôle                                        |
|------------|---------------------|-------------------------------------------------|
| Mobile     | Déplacer le surfeur | Joystick fixe bas-gauche (zone 18 % × 82 %)    |
| Mobile     | Figure (backflip)   | Double-tap n'importe où sur l'écran             |
| Bureau     | Déplacer le surfeur | Flèches directionnelles / ZQSD                  |
| Bureau     | Figure (backflip)   | Barre espace                                    |
| Tous       | Pause               | Bouton pause (haut de l'écran)                  |

**Détail du joystick mobile :**
- Cercle de base fixe (rayon 72 px), semi-transparent, avec croix de guidage.
- Knob bleu (rayon 30 px) qui suit le doigt, clampé dans le rayon de la base.
- Direction proportionnelle à l'offset du knob (pleine vitesse au bord, zone morte 8 px).
- Activation si le premier contact tombe dans un rayon de 100 px autour du centre.
- Relâchement du doigt : surfeur s'arrête immédiatement.

### 3.3 Interactions dans les menus

- **Menu principal** : boutons de navigation (Jouer, Boutique, Paramètres), clic sur le surfeur animé pour lancer une partie.
- **Boutique / Dressing** : grille 3 colonnes de cartes. Chaque carte affiche un aperçu visuel, le nom, le prix/statut, et un bouton Acheter / Équiper / Équipé.
- **Paramètres** : sliders pour les volumes et la sensibilité, toggle pour la vibration, bouton sourdine, bouton de reset avec double-confirmation (3 s entre les deux appuis).
- **Game Over** : score final, high score, bouton Rejouer, bouton Menu.
- **Pause** : Reprendre, Recommencer, Quitter.

---

## 4. Apparence et comportement visuel

### 4.1 Style graphique général
- **100 % procédural** : tous les éléments (personnages, planches, obstacles, décors, vagues, ciels) sont dessinés avec les primitives Godot (`draw_circle`, `draw_colored_polygon`, `draw_line`, etc.).
- Palette chaude : ciel orangé-doré → bleu océan, eau turquoise → bleu profond.
- Animations en temps réel : vagues sinusoïdales multicouches, balancement du surfeur, bob des obstacles.

### 4.2 Personnages
Quatre personnages avec dessins détaillés :
- **Surfeur Classique** : combinaison bleue standard.
- **Surfeuse Pro** : combinaison rose/violet.
- **Rider Neon** : combinaison jaune fluo avec lignes lumineuses.
- **Water Ninja** : combinaison noire high-tech avec armure et lignes cyber-bleues.

### 4.3 Planches de surf
Cinq planches différenciées par couleur de base et bande centrale :
Classique (blanc/bleu), Flammes (orange/rouge), Tropicale (vert/jaune), Galaxy (noir/violet), Or (jaune/orange).

### 4.4 Obstacles
- **Requin** : silhouette gris-anthracite avec aileron dorsal.
- **Méduse** : dôme rose translucide avec tentacules animés.

### 4.5 Effets spéciaux en jeu
- **Boost actif** : aura pulsante cyan-vert autour du surfeur + rayons animés.
- **Figure** : saut parabolique (110 px d'élévation), rotation complète, spray de gouttelettes autour du surfeur.
- **Collecte de SurfCoin** : pièce dorée avec reflet et texte "SC".
- **Étoile boost** : étoile à 5 branches jaune-doré avec rotation et halo lumineux.

### 4.6 Menu principal — progression visuelle
Le décor du menu évolue selon le total XP du joueur :
- **< 200 XP** : deux cabanes sur pilotis avec planches de surf.
- **200–499 XP** : grande maison avec terrasse et piscine.
- **≥ 500 XP** : château avec tours, remparts et drapeau.

### 4.7 Interface HUD (pendant la partie)
- Score en haut au centre (grand, blanc).
- XP et SurfCoins en haut à gauche.
- Bouton pause en haut à droite.
- Joystick fixe en bas à gauche (mobile uniquement, dessiné dans le `_draw()` du GameLevel).

### 4.8 Interface Boutique / Dressing
- Panneau 720 × 520 px centré, fond sombre semi-transparent, bordure bleue arrondie.
- Grille 3 colonnes. Cartes avec :
  - Bordure **verte** = équipé, **bleue** = possédé, **grise** = non possédé.
  - Aperçu en hauteur fixe 95 px (dessin procédural de la planche ou du personnage).
  - Bouton désactivé si déjà équipé, grisé si pas assez de fonds (boutique).

---

## 5. Exigences non-fonctionnelles et limites

| Critère              | Exigence                                                                 |
|----------------------|--------------------------------------------------------------------------|
| **Performance**      | 60 FPS stables sur appareils mobile milieu de gamme (2021+)             |
| **Compatibilité**    | Godot 4.x — export Android et iOS. Fonctionne aussi sur bureau.         |
| **Assets externes**  | Zéro fichier image, audio ou police externe requis (tout procédural)    |
| **Sauvegarde**       | Persistance locale uniquement (`user://save.json`), pas de cloud        |
| **Taille**           | Binaire exporté < 50 Mo (pas d'assets lourds)                           |
| **Accessibilité**    | Sensibilité des contrôles ajustable (20–150 %). Bouton sourdine global. |
| **Sécurité**         | Pas de réseau, pas de serveur, pas de données personnelles transmises    |
| **Hors-scope**       | Multijoueur, classements en ligne, achats intégrés, publicités          |
| **Hors-scope**       | Niveaux scriptés, boss, histoire, tutoriel interactif                   |

---

## 6. Comment mesurer si le projet est réussi

### 6.1 Métriques de rétention (prioritaires)
| Indicateur                              | Cible                                      |
|-----------------------------------------|--------------------------------------------|
| Durée moyenne d'une session             | ≥ 3 minutes                                |
| Taux de retour J+1 (joueurs qui rejouent le lendemain) | ≥ 40 %               |
| Nombre de parties par session           | ≥ 3 parties consécutives en moyenne        |

### 6.2 Métriques de progression
| Indicateur                              | Cible                                      |
|-----------------------------------------|--------------------------------------------|
| % de joueurs atteignant 200 XP          | ≥ 60 % des joueurs actifs                  |
| % de joueurs ayant acheté au moins 1 item en boutique | ≥ 35 %             |
| % de joueurs ayant utilisé le dressing  | ≥ 50 %                                     |

### 6.3 Métriques de qualité technique
| Indicateur                              | Cible                                      |
|-----------------------------------------|--------------------------------------------|
| Taux de crash / session                 | < 0,5 %                                    |
| FPS moyen en jeu (mobile cible)         | ≥ 58 FPS                                   |
| Temps de chargement au lancement        | < 2 secondes                               |

### 6.4 Signal qualitatif de succès
Le projet est considéré réussi si un testeur externe, sans explication préalable, est capable de :
1. Démarrer une partie en moins de 10 secondes depuis le lancement.
2. Comprendre les contrôles sans tutoriel en moins de 30 secondes.
3. Acheter et équiper un item depuis la boutique sans aide.
