# Partie 4 — Élaboration du Plan de Reprise

> **Statut** : Complété

## 4.1 Constats Principaux

L'audit des parties 1 à 3 a mis en évidence les problèmes suivants :

| # | Constat | Sévérité | Impact |
|---|---|---|---|
| 1 | Java 1.8, Spring Boot 2.1.4, Hibernate 5.x — tous EOL | Critique | Bloque toute évolution |
| 2 | Failles de sécurité (CSRF désactivé, password encoder déprécié) | Critique | Vulnérabilité en production |
| 3 | Couverture de tests ~0% (2 classes / 335 fichiers) | Critique | Refactorisation risquée |
| 4 | God Module (`wallride-core` = 100% de la logique) | Majeur | Maintenance impossible |
| 5 | God Classes (ArticleService 697 lignes, PageService 667 lignes) | Majeur | Complexité excessive |
| 6 | Frontend couplé au build Maven | Majeur | Pas de déploiement indépendant |
| 7 | Dépendances dépréciées (Spring Mobile, commons-lang 2, GA v3) | Moyen | Dette technique croissante |
| 8 | Absence de CI/CD | Moyen | Pas de filet de sécurité |
| 9 | Bus factor = 1 (74% commits par un seul dev) | Moyen | Risque organisationnel |

## 4.2 Définition des Priorités — 3 Actions Prioritaires

### Priorité 1 : Mise à jour des technologies critiques

**Objectif** : Passer sur un socle technique supporté et sécurisé.

| Action | De | Vers |
|---|---|---|
| Java | 1.8 | 21 (LTS) |
| Spring Boot | 2.1.4.RELEASE | 3.4.x |
| Spring Framework | 5.1.x | 6.2.x |
| Hibernate ORM | 5.3.x | 6.6.x |
| Hibernate Search | 5.10.5.Final | 7.2.x |
| Lucene | 5.5.5 | 9.12.x |
| `javax.*` | javax | `jakarta.*` |

**Pourquoi en premier** : tant que le socle technique est obsolète, aucune autre amélioration n'est viable. Les patches de sécurité, les nouvelles fonctionnalités du framework et le support communautaire dépendent de cette migration.

### Priorité 2 : Correction des problèmes de sécurité

**Objectif** : Éliminer les vulnérabilités structurelles identifiées.

| Action | Détail |
|---|---|
| Activer CSRF | Retirer `.csrf().disable()` des configurations admin et guest |
| Migrer le password encoder | `StandardPasswordEncoder` → `BCryptPasswordEncoder` |
| Réactiver les headers de sécurité | HSTS, X-Frame-Options, Cache-Control |
| Mettre à jour commons-fileupload | Version 1.3.3 → 1.5+ (CVEs connues) |
| Mettre à jour jsoup | Version 1.7.2 → 1.18+ |
| Résoudre les issues #98 et #122 | Problèmes de sécurité signalés sur GitHub |

**Pourquoi en deuxième** : ces failles exposent le système en production. Certaines corrections (CSRF, password encoder) sont indépendantes de la migration Spring Boot et peuvent être commencées en parallèle.

### Priorité 3 : Refactoring des modules les plus problématiques

**Objectif** : Réduire la complexité et améliorer la maintenabilité.

| Action | Détail |
|---|---|
| Découper `wallride-core` | Séparer en modules : domain, service, web-admin, web-guest |
| Refactoriser ArticleService | Extraire en sous-services : ArticleCreateService, ArticleSearchService, etc. |
| Refactoriser PageService | Même approche que ArticleService |
| Découpler le frontend | Séparer le build Node.js du build Maven, exposer une API REST |
| Supprimer les dépendances mortes | Spring Mobile, commons-lang 2, Google Analytics v3 |

## 4.3 Priorisation (Impact / Effort)

```mermaid
quadrantChart
    title Matrice Impact / Effort
    x-axis Effort Faible --> Effort Élevé
    y-axis Impact Faible --> Impact Élevé
    quadrant-1 Faire en priorité
    quadrant-2 Planifier
    quadrant-3 Quick wins
    quadrant-4 Reporter
    Activer CSRF: [0.2, 0.8]
    Migrer password encoder: [0.25, 0.7]
    Réactiver headers sécurité: [0.15, 0.65]
    Ajouter tests unitaires: [0.5, 0.85]
    Migration Java 21: [0.7, 0.95]
    Migration Spring Boot 3: [0.85, 0.95]
    Migration Hibernate 6: [0.8, 0.8]
    Découper wallride-core: [0.9, 0.75]
    Découpler frontend: [0.65, 0.6]
    Supprimer dépendances mortes: [0.3, 0.4]
    Mettre en place CI/CD: [0.4, 0.7]
```

## 4.4 Stratégie de Refactorisation

### Élimination des dépendances obsolètes

| Bibliothèque à remplacer | Remplacement | Effort |
|---|---|---|
| `spring-mobile-device` | Supprimer (responsive CSS suffit) | Faible |
| `commons-lang` 2.4 | `commons-lang3` 3.17.x | Faible |
| `javax.mail` 1.4.1 | `jakarta.mail` 2.1.x | Moyen |
| `Google Analytics v3` | GA Data API v4 ou suppression | Moyen |
| `AWS SDK v1` | AWS SDK v2 | Moyen |
| `commons-fileupload` 1.3.3 | `commons-fileupload2` ou Spring multipart | Moyen |
| `Infinispan` (cache) | Spring Cache + Caffeine ou Redis | Élevé |
| `Hibernate Search` 5.10 | Hibernate Search 7.x (réécriture API) | Élevé |

### Réduction de la dette technique — Fichiers prioritaires

| Fichier | Lignes | Action |
|---|---|---|
| `ArticleService.java` | 697 | Découper en 4-5 sous-services par responsabilité |
| `PageService.java` | 667 | Même approche |
| `UserService.java` | 458 | Séparer authentification / gestion de profil |
| `WallRideSecurityConfiguration` | — | Réécrire avec Spring Security 6.x et bonnes pratiques |
| Contrôleurs admin (117 fichiers) | — | Identifier la duplication, extraire un contrôleur CRUD générique |

### Amélioration de la maintenabilité

1. **Documentation** :
   - Ajouter un README technique avec les instructions de build et déploiement
   - Documenter l'architecture dans un ADR (Architecture Decision Record)
   - Ajouter des JavaDoc sur les services et entités principaux

2. **Réorganisation du code** :
   - Adopter une structure par domaine fonctionnel (article, page, user, blog) au lieu de par couche technique
   - Séparer les DTOs de requête des DTOs de réponse
   - Introduire des interfaces pour les services (faciliter le testing)

3. **Qualité de code** :
   - Standardiser l'injection de dépendances (utiliser uniquement `@Autowired` ou constructor injection)
   - Supprimer le code commenté
   - Appliquer un formateur de code uniforme (Checkstyle ou Spotless)

### Mise en place CI/CD et tests

| Action | Outil | Objectif |
|---|---|---|
| Pipeline CI | GitHub Actions | Build + tests automatiques à chaque PR |
| Analyse statique | SonarCloud | Suivi continu de la dette technique |
| Tests unitaires | JUnit 5 + Mockito | Couverture > 60% sur les services |
| Tests d'intégration | Spring Boot Test + H2 | Vérifier les repositories et configs |
| Tests E2E | Selenium ou Playwright | Vérifier les parcours utilisateur critiques |
| Conteneurisation | Docker + Docker Compose | Environnement de développement reproductible |
| Formatage | Checkstyle / Spotless | Uniformité du code |

## 4.5 Actions par Horizon Temporel

### Court terme (0-3 mois) — Stabilisation

```mermaid
gantt
    title Plan de Reprise — Court Terme
    dateFormat  YYYY-MM
    axisFormat  %b %Y

    section Sécurité
    Activer CSRF                      :crit, sec1, 2026-04, 2w
    Migrer password encoder           :crit, sec2, after sec1, 1w
    Réactiver headers sécurité        :sec3, after sec1, 1w
    Mettre à jour jsoup + fileupload  :sec4, after sec2, 1w

    section CI/CD
    GitHub Actions (build + test)     :ci1, 2026-04, 1w
    Intégration SonarCloud            :ci2, after ci1, 1w
    Docker Compose dev                :ci3, after ci1, 2w

    section Tests
    Tests services critiques          :test1, 2026-04, 4w
    Tests repositories                :test2, after test1, 3w

    section Nettoyage
    Supprimer Spring Mobile           :clean1, 2026-04, 2d
    Supprimer dépendances mortes      :clean2, after clean1, 1w
    Supprimer code commenté           :clean3, after clean2, 3d
```

### Moyen terme (3-6 mois) — Migration technique

| Phase | Action | Durée estimée |
|---|---|---|
| Phase A | Migration Java 8 → Java 17 (étape intermédiaire) | 3 semaines |
| Phase B | Migration Spring Boot 2.1 → 2.7 (dernière 2.x) | 4 semaines |
| Phase C | Migration `javax` → `jakarta` + Spring Boot 3.x | 4 semaines |
| Phase D | Migration Hibernate Search 5.x → 6.x/7.x | 3 semaines |
| Phase E | Découpler le build frontend (API REST) | 3 semaines |

### Long terme (6-12 mois) — Modernisation architecturale

| Phase | Action | Durée estimée |
|---|---|---|
| Phase F | Découper `wallride-core` en modules par domaine | 6 semaines |
| Phase G | Passage Java 17 → Java 21 (LTS) | 2 semaines |
| Phase H | Conteneurisation complète (Docker + K8s) | 3 semaines |
| Phase I | Observabilité (Micrometer, structured logging) | 2 semaines |
| Phase J | Migration frontend vers SPA moderne (React/Vue) | 8 semaines |

## 4.6 Synthèse

### Roadmap globale

```mermaid
timeline
    title Roadmap de Modernisation WallRide
    section Court terme (0-3 mois)
        Sécurité : Activer CSRF, BCrypt, headers
        CI/CD : GitHub Actions, SonarCloud, Docker
        Tests : Couverture > 40% sur les services
        Nettoyage : Supprimer dépendances mortes
    section Moyen terme (3-6 mois)
        Migration : Java 8 → 17, Spring Boot 2 → 3
        Hibernate : ORM 5 → 6, Search 5 → 7
        Frontend : Découplage du build Maven
    section Long terme (6-12 mois)
        Architecture : Découper wallride-core
        Java : 17 → 21 LTS
        Infra : Docker, Kubernetes, observabilité
        Frontend : Migration vers SPA moderne
```

### Effort total estimé

| Horizon | Effort estimé | Équipe recommandée |
|---|---|---|
| Court terme | 2-3 mois | 1-2 développeurs |
| Moyen terme | 3-4 mois | 2-3 développeurs |
| Long terme | 4-6 mois | 2-3 développeurs |
| **Total** | **9-13 mois** | **2-3 développeurs** |

**Coût estimé** : entre 9 et 13 mois-homme de développement pour une modernisation complète. Ce chiffre suppose une équipe familière avec l'écosystème Spring Boot et les pratiques de migration.
