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

| Métrique | Valeur |
|---|---|
| Nombre total de bugs | **15** |
| Bugs critiques (Critical) | 0 |
| Bugs majeurs (Major) | **14** |
| Bugs mineurs (Minor) | 1 |
| **Rating Reliability** | **C** |

**Fichiers les plus impactés** :

| Fichier | Bugs |
|---|---|
| `web/controller/admin/article/ArticleEditController.java` | 3 |
| `web/controller/admin/page/PageEditController.java` | 3 |
| `web/support/Posts.java` | 2 |
| `web/controller/admin/customfield/CustomFieldEditController.java` | 1 |
| `web/controller/admin/article/ArticleCreateController.java` | 1 |
| `service/PostService.java` | 1 |
| `support/ProxySecureChannelProcessor.java` | 1 |

> Les bugs sont concentrés dans les **contrôleurs admin** (8/15) et la couche **web support** (3/15). Les services métier sont relativement épargnés (1/15).

### Vulnérabilités

| Métrique | Valeur |
|---|---|
| Nombre total de vulnérabilités | **0** |
| Security Hotspots | **14** (0% reviewed) |
| **Rating Security** | **A** |
| **Rating Security Review** | **E** |

**Vulnérabilités identifiées par analyse du code source** :

Indépendamment de SonarCloud, l'analyse manuelle du code révèle des failles de sécurité graves :

1. **CSRF désactivé** : les configurations de sécurité admin et guest désactivent explicitement la protection CSRF (`.csrf().disable()`)
2. **StandardPasswordEncoder** : utilisation d'un encodeur de mots de passe déprécié au lieu de BCrypt
3. **Headers de sécurité désactivés** : `frameOptions().disable()`, `cacheControl().disable()`, `httpStrictTransportSecurity().disable()`
4. **Issues GitHub non résolues** : les issues #98 et #122 signalent des problèmes de sécurité non corrigés

### Code Smells

| Métrique | Valeur |
|---|---|
| Nombre total de code smells | **428** |
| Critiques (Critical) | **99** |
| Majeurs (Major) | **189** |
| Mineurs (Minor) | **139** |
| Info | 1 |
| Dette technique | **7 jours 1 heure** |
| **Rating Maintainability** | **A** |

**Principaux problèmes relevés** (observés dans le code source) :

- **God Classes** : `ArticleService` (697 lignes), `PageService` (667 lignes), `UserService` (458 lignes)
- **God Module** : `wallride-core` contient 335 fichiers Java — 100% de la logique métier
- **Code commenté** : code AWS et actuator laissé en commentaires dans les fichiers de configuration
- **Mélange de standards DI** : utilisation simultanée de `@Resource` (JSR-250), `@Inject` (JSR-330) et `@Autowired` (Spring)
- **Couche web surdimensionnée** : 159 fichiers dans le package `web` (47,5% du code total)

### Couverture de Code

| Métrique | Valeur |
|---|---|
| Couverture globale | **0.0%** |
| Lignes à couvrir | **9 000** |
| Unit Tests | **aucun exécuté** |
| Fichiers de test | 2 (sur 340 fichiers source) |
| Classes de test | `BootstrapTests.java`, `BlogTests.java` |

> La couverture de tests est catastrophique : 0% sur 9 000 lignes à couvrir. Cela rend toute refactorisation extrêmement risquée.

### Duplication

| Métrique | Valeur |
|---|---|
| Taux de duplication | **16.4%** |
| Blocs dupliqués | **325** |
| Lignes analysées | **22 000** |

> Le taux de duplication de 16.4% est très élevé (seuil recommandé : < 5%). Cela confirme la duplication entre les contrôleurs admin d'Articles, Pages et Posts (opérations CRUD similaires).

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

### Ratings obtenus

| Dimension | Rating | Détail |
|---|---|---|
| Reliability | **C** | 15 bugs (14 majeurs), concentrés dans les contrôleurs admin |
| Security | **A** | 0 vulnérabilité détectée par SonarQube |
| Security Review | **E** | 14 hotspots, 0% revus |
| Maintainability | **A** | 428 code smells, 7j1h de dette technique |
| Coverage | **—** | 0.0% (aucun test exécuté) |
| Duplication | **—** | 16.4% (325 blocs dupliqués) |

> **Note importante** : le rating Security **A** est trompeur. SonarQube ne détecte pas les vulnérabilités liées à la configuration Spring Security (CSRF désactivé, headers désactivés, password encoder déprécié) car ce sont des choix de configuration, pas des patterns de code vulnérable. Les 14 Security Hotspots non revus et l'analyse manuelle révèlent des failles structurelles graves que les ratings automatiques ne capturent pas.
