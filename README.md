# TP15 — Diagnostic et Plan de Reprise

TP n°15 — Audit technique et plan de reprise d'un CMS Java open-source abandonné : **WallRide**.

## Contexte

Le projet [WallRide](https://github.com/tagbangers/wallride) est un CMS Java basé sur Spring Boot, abandonné depuis plusieurs années. Ce TP consiste à réaliser un diagnostic complet de l'état du projet (dette technique, vulnérabilités, obsolescence des dépendances, érosion architecturale) et à proposer un plan de reprise structuré.

## Objectifs

- Forker le dépôt WallRide et l'analyser avec SonarCloud
- Identifier la dette technique (bugs, vulnérabilités, code smells)
- Analyser l'obsolescence des dépendances (Spring Boot, Java 1.8, Hibernate, pom.xml)
- Évaluer l'érosion architecturale (couplage, dépendances cycliques, monolithe)
- Proposer un plan de reprise priorisé (refactoring, CI/CD, roadmap)
- Rédiger un rapport d'audit de 3-4 pages avec captures SonarCloud

## Approche

Ce travail adopte une posture d'auditeur technique, en analysant méthodiquement chaque dimension de la dette avant de proposer des actions correctives priorisées.

## Structure du Projet

```
├── analysis/       # Analyses détaillées par partie
├── docs/           # Livrables finaux (rapport + plan)
├── screenshots/    # Captures SonarCloud et outils d'analyse
└── README.md       # Ce fichier
```

### Livrables principaux

- `docs/rapport-audit.md` — Rapport d'audit (3-4 pages, captures incluses)
- `docs/plan-reprise.md` — Plan de reprise détaillé avec roadmap

### Analyses par partie

- `analysis/partie-1-sonarcloud.md` — Analyse SonarCloud (bugs, vulnérabilités, code smells, couverture)
- `analysis/partie-2-dette-technique.md` — Obsolescence des dépendances et dette technique
- `analysis/partie-3-erosion-architecturale.md` — Érosion architecturale et couplage
- `analysis/partie-4-plan-reprise.md` — Stratégie de reprise et priorisation

## Livrables

| Livrable | Format | Description |
|---|---|---|
| Rapport d'audit | Markdown / PDF | 3-4 pages avec captures SonarCloud |
| Plan de reprise | Markdown / PDF | Roadmap priorisée avec stratégie de refactoring |

## Phases de Travail

1. **Setup** — Fork WallRide, configuration SonarCloud, initialisation du dépôt
2. **Analyse SonarCloud** — Lancement de l'analyse, collecte des métriques et captures
3. **Analyse des dépendances** — Étude du pom.xml, versions obsolètes, CVE connues
4. **Érosion architecturale** — Structure modulaire, couplage, dépendances cycliques
5. **Plan de reprise** — Priorisation, stratégie de refactoring, CI/CD, roadmap
6. **Rédaction** — Rapport d'audit et plan de reprise finaux

## Workflow Git

- Une branche par phase de travail
- Commits fréquents avec convention Angular
- Pull requests détaillées pour chaque phase
- Validation par review avant merge

## État d'avancement

- [ ] Phase 1 — Setup du projet
- [ ] Phase 2 — Analyse SonarCloud
- [ ] Phase 3 — Analyse des dépendances
- [ ] Phase 4 — Érosion architecturale
- [ ] Phase 5 — Plan de reprise
- [ ] Phase 6 — Rédaction des livrables finaux

---

**Auteur** : Benoit BREMAUD
**Cours** : Architecture Logicielle - M1 Ynov
**Date** : Mars 2026
