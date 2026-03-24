# Partie 1 — Analyse SonarCloud

> **Statut** : En cours

## 1.1 Configuration du Fork sur SonarCloud

### Étape 1 : Fork du repository

Le projet WallRide original est hébergé sur GitHub : [tagbangers/wallride](https://github.com/tagbangers/wallride).

Un fork a été créé sur le compte `benoit-bremaud` :
- **Repository source** : `tagbangers/wallride`
- **Fork** : `benoit-bremaud/wallride`

### Étape 2 : Import dans SonarCloud

1. Connexion à [SonarCloud](https://sonarcloud.io) avec le compte GitHub
2. Clic sur **"Create new project"**
3. Sélection de **GitHub** comme source
4. Choix du fork `benoit-bremaud/wallride`
5. Sélection de **"New version"** comme méthode d'analyse
6. Configuration par défaut (aucune modification nécessaire)

> **Note** : Le Quality Gate ne sera pas validé à la première analyse (il nécessite une seconde exécution). On se concentre sur les métriques disponibles.

### Étape 3 : Lancement de l'analyse

L'analyse démarre automatiquement après l'importation du projet. SonarCloud analyse le code source Java, JavaScript, HTML et CSS du projet.

## 1.2 Résultats de l'Analyse

### Bugs

<!-- TODO: Remplir avec les données SonarCloud réelles -->

| Métrique | Valeur |
|---|---|
| Nombre total de bugs | _À compléter_ |
| Bugs critiques (Critical) | _À compléter_ |
| Bugs majeurs (Major) | _À compléter_ |
| Bugs mineurs (Minor) | _À compléter_ |

**Fichiers les plus impactés** :

_À compléter avec les captures SonarCloud_

### Vulnérabilités

| Métrique | Valeur |
|---|---|
| Nombre total de vulnérabilités | _À compléter_ |
| Vulnérabilités critiques | _À compléter_ |
| Security Hotspots | _À compléter_ |

**Vulnérabilités identifiées par analyse du code source** :

Indépendamment de SonarCloud, l'analyse manuelle du code révèle des failles de sécurité graves :

1. **CSRF désactivé** : les configurations de sécurité admin et guest désactivent explicitement la protection CSRF (`.csrf().disable()`)
2. **StandardPasswordEncoder** : utilisation d'un encodeur de mots de passe déprécié au lieu de BCrypt
3. **Headers de sécurité désactivés** : `frameOptions().disable()`, `cacheControl().disable()`, `httpStrictTransportSecurity().disable()`
4. **Issues GitHub non résolues** : les issues #98 et #122 signalent des problèmes de sécurité non corrigés

### Code Smells

| Métrique | Valeur |
|---|---|
| Nombre total de code smells | _À compléter_ |
| Dette technique (en jours) | _À compléter_ |
| Ratio de dette technique | _À compléter_ |

**Principaux problèmes relevés** (observés dans le code source) :

- **God Classes** : `ArticleService` (697 lignes), `PageService` (667 lignes), `UserService` (458 lignes)
- **God Module** : `wallride-core` contient 335 fichiers Java — 100% de la logique métier
- **Code commenté** : code AWS et actuator laissé en commentaires dans les fichiers de configuration
- **Mélange de standards DI** : utilisation simultanée de `@Resource` (JSR-250), `@Inject` (JSR-330) et `@Autowired` (Spring)
- **Couche web surdimensionnée** : 159 fichiers dans le package `web` (47,5% du code total)

### Couverture de Code

| Métrique | Valeur |
|---|---|
| Couverture globale | **~0%** (quasi nulle) |
| Fichiers de test | 2 (sur 335 fichiers source) |
| Classes de test | `BootstrapTests.java`, `BlogTests.java` |

> La couverture de tests est catastrophique : seulement 2 classes de test pour un projet de 335 fichiers Java. Cela rend toute refactorisation extrêmement risquée.

### Duplication

| Métrique | Valeur |
|---|---|
| Taux de duplication | _À compléter via SonarCloud_ |
| Blocs dupliqués | _À compléter_ |

**Observation** : la structure des contrôleurs admin (117 fichiers) et des services suggère un taux de duplication élevé, notamment entre les opérations CRUD d'Articles, Pages et Posts.

## 1.3 Captures d'écran

<!-- Insérer les captures depuis le dossier screenshots/ -->

> **TODO** : Ajouter les captures d'écran SonarCloud dans le dossier `screenshots/` :
> - `screenshots/sonarcloud-dashboard.png` — Vue d'ensemble du projet
> - `screenshots/sonarcloud-bugs.png` — Liste des bugs
> - `screenshots/sonarcloud-vulnerabilities.png` — Vulnérabilités détectées
> - `screenshots/sonarcloud-code-smells.png` — Code smells principaux
> - `screenshots/sonarcloud-debt.png` — Répartition de la dette technique

## 1.4 Interprétation

### Constats principaux

1. **Projet abandonné depuis 7 ans** (dernier commit : avril 2019) — aucune mise à jour de sécurité depuis
2. **Couverture de tests quasi nulle** — toute modification comporte un risque de régression non détectable
3. **Failles de sécurité structurelles** — CSRF désactivé, encodeur de mots de passe déprécié, headers de sécurité désactivés
4. **Dette technique concentrée** — les services métier (Article, Page, User) accumulent la majorité de la complexité
5. **Bus factor critique** — 74% des commits par un seul développeur (ogawa-takeshi)

### Rating attendu

Compte tenu de l'analyse manuelle, on s'attend aux ratings SonarCloud suivants :

| Dimension | Rating attendu | Justification |
|---|---|---|
| Reliability | **D ou E** | God classes, code mort, absence de tests |
| Security | **E** | CSRF désactivé, failles non corrigées |
| Maintainability | **D ou E** | Dette technique massive, couplage fort |
| Coverage | **E** | ~0% de couverture |
