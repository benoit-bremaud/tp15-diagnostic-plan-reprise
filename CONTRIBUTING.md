# Contributing — TP15 Diagnostic et Plan de Reprise

Ce document décrit les conventions et le workflow à suivre pour contribuer à ce projet.

## Table des matières

- [Workflow Git](#workflow-git)
- [Convention de branches](#convention-de-branches)
- [Convention de commits](#convention-de-commits)
- [Créer une issue](#créer-une-issue)
- [Créer une Pull Request](#créer-une-pull-request)
- [Labels](#labels)
- [Milestones](#milestones)
- [Reviewers](#reviewers)

---

## Workflow Git

1. Toujours travailler sur une **branche dédiée** (jamais directement sur `main`)
2. Chaque branche correspond à **une issue**
3. Ouvrir une **Pull Request** vers `main` une fois le travail terminé
4. Obtenir une **review** avant de merger
5. Supprimer la branche après merge

## Convention de branches

### Format

```
<type>/issue-<number>-<short-description>
```

### Types autorisés

| Type | Usage |
|---|---|
| `chore` | Configuration, setup, maintenance |
| `analysis` | Analyse technique (parties 1-4) |
| `docs` | Rédaction de livrables et documentation |
| `fix` | Correction d'une erreur |
| `refactor` | Réorganisation sans changement fonctionnel |

### Exemples

```
chore/issue-4-issue-templates-contributing
analysis/issue-9-dependency-versions
docs/issue-17-rapport-audit
```

## Convention de commits

Ce projet utilise la convention **Angular (Conventional Commits)**.

### Format

```
<type>(<scope>): <description courte>
```

### Types autorisés

| Type | Usage |
|---|---|
| `chore` | Configuration, setup, CI/CD |
| `analysis` | Ajout ou modification d'une analyse |
| `docs` | Documentation, livrables, README |
| `fix` | Correction d'erreur |
| `refactor` | Réorganisation de code ou contenu |
| `style` | Formatting, mise en forme (pas de changement de contenu) |

### Scopes autorisés

| Scope | Usage |
|---|---|
| `setup` | Configuration de l'environnement |
| `part1` | Partie 1 — Analyse SonarCloud |
| `part2` | Partie 2 — Dette technique et dépendances |
| `part3` | Partie 3 — Érosion architecturale |
| `part4` | Partie 4 — Plan de reprise |
| `deliverable` | Livrables finaux (rapport, plan) |

### Exemples

```
chore(setup): add issue templates and CONTRIBUTING.md
analysis(part2): document Spring Boot version obsolescence
docs(deliverable): write audit report introduction
fix(part1): correct SonarCloud metrics in analysis
```

### Règles

- La description commence par un **verbe à l'infinitif en anglais** (add, fix, update, document…)
- Pas de point final
- Maximum 72 caractères pour la première ligne
- Corps optionnel séparé par une ligne vide

## Créer une issue

### Étapes

1. Aller dans l'onglet **Issues** du repo
2. Cliquer sur **New issue**
3. Choisir le **template** adapté :
   - **Configuration / Setup** — pour les tâches de mise en place
   - **Analyse technique** — pour les analyses (parties 1-4)
   - **Livrable** — pour la rédaction de documents finaux
4. Remplir tous les champs obligatoires
5. Configurer les métadonnées :

| Métadonnée | Valeur |
|---|---|
| **Assignees** | `benoit-bremaud` |
| **Labels** | Type (`type:setup/analysis/deliverable`) + Partie (`part:1-4`) + Priorité (`priority:high/medium/low`) |
| **Project** | `TP15 — Diagnostic et Plan de Reprise` |
| **Milestone** | `Setup` / `Analyses` / `Livrables` (selon la phase) |

### Correspondance Milestone / Issues

| Milestone | Issues concernées |
|---|---|
| **Setup** | Configuration, templates, SonarCloud (#1-#5) |
| **Analyses** | Parties 1-3 du TP (#6-#13) |
| **Livrables** | Partie 4 + rédaction finale (#14-#19) |

## Créer une Pull Request

### Avant de créer la PR

- [ ] Tous les commits suivent la convention Angular
- [ ] La branche est à jour avec `main` (`git rebase main`)
- [ ] Le contenu est complet et relu

### Template de PR

Le repo dispose d'un template automatique (`.github/pull_request_template.md`). Remplir :

1. **Objet** — description courte du périmètre
2. **Issue liée** — `Closes #<number>`
3. **Changements réalisés** — liste des modifications
4. **Phase concernée** — cocher la phase du TP
5. **Vérifications** — checklist de validation
6. **Notes de revue** — points d'attention pour le reviewer

### Métadonnées de la PR

| Métadonnée | Valeur |
|---|---|
| **Assignees** | `benoit-bremaud` |
| **Labels** | Mêmes labels que l'issue liée + `claude-code-assisted` si applicable |
| **Project** | `TP15 — Diagnostic et Plan de Reprise` |
| **Milestone** | Même milestone que l'issue liée |
| **Reviewers** | `benoit-bremaud` + `copilot-pull-request-reviewer` |

### Commande CLI (référence)

```bash
# Créer la PR
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Objet
...

## Issue liée
Closes #XX

## Changements réalisés
- ...

## Phase concernée
- [ ] Phase 1 — Setup du projet
- [ ] Phase 2 — Analyse SonarCloud
- [ ] Phase 3 — Analyse des dépendances
- [ ] Phase 4 — Érosion architecturale
- [ ] Phase 5 — Plan de reprise
- [ ] Phase 6 — Rédaction des livrables finaux

## Checklist
- [ ] Les commits suivent la convention Angular
- [ ] La branche est à jour avec `main`
- [ ] Relecture fonctionnelle effectuée
- [ ] Impact documentation vérifié
- [ ] Aucun conflit avec `main`
EOF
)"

# Ajouter les métadonnées
gh api repos/benoit-bremaud/tp15-diagnostic-plan-reprise/issues/PR_NUMBER/assignees \
  -X POST --input - <<< '{"assignees": ["benoit-bremaud"]}'

gh api repos/benoit-bremaud/tp15-diagnostic-plan-reprise/issues/PR_NUMBER/labels \
  -X POST --input - <<< '{"labels": ["type:setup", "claude-code-assisted"]}'

# Lier au projet TP15
PR_ID=$(gh api repos/benoit-bremaud/tp15-diagnostic-plan-reprise/pulls/PR_NUMBER --jq '.node_id')
gh api graphql -f query='mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}' \
  -f p="PVT_kwHOB8rwIc4BSiW3" -f c="$PR_ID"

# Demander review Copilot (best-effort)
gh api repos/benoit-bremaud/tp15-diagnostic-plan-reprise/pulls/PR_NUMBER/requested_reviewers \
  -X POST --input - <<< '{"reviewers": ["copilot-pull-request-reviewer"]}'
```

## Labels

### Par type

| Label | Description |
|---|---|
| `type:setup` | Configuration et mise en place |
| `type:analysis` | Analyse technique |
| `type:deliverable` | Livrable final |

### Par partie du TP

| Label | Description |
|---|---|
| `part:1` | Partie 1 — Analyse SonarCloud |
| `part:2` | Partie 2 — Dette technique et dépendances |
| `part:3` | Partie 3 — Érosion architecturale |
| `part:4` | Partie 4 — Plan de reprise |

### Par priorité

| Label | Description |
|---|---|
| `priority:high` | Priorité haute (P0) — bloquant |
| `priority:medium` | Priorité moyenne (P1) |
| `priority:low` | Priorité basse (P2) |

### Spécial

| Label | Description |
|---|---|
| `claude-code-assisted` | Issue créée ou traitée avec Claude Code |

## Milestones

| Milestone | Description | Échéance |
|---|---|---|
| **Setup** | Configuration de l'environnement | 30/03/2026 |
| **Analyses** | Analyses techniques (Parties 1-3) | 13/04/2026 |
| **Livrables** | Rédaction des livrables finaux | 27/04/2026 |

## Reviewers

| Reviewer | Rôle |
|---|---|
| `benoit-bremaud` | Self-review obligatoire |
| `copilot-pull-request-reviewer` | Review automatisée (best-effort) |

---

**Auteur** : Benoit BREMAUD
**Dernière mise à jour** : Mars 2026
