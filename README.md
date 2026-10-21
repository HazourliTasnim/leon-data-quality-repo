# Leon - Data Quality B2B

Application **Streamlit** connectee a **Snowflake** pour le pilotage de la qualite des donnees clients B2B.

Analyse automatisee des identifiants legaux (SIREN, SIRET, TVA intracommunautaire), detection des anomalies, corrections assistees par IA (Cortex AI), et export CRM.

---

## Prerequis Snowflake

L'application s'appuie sur des objets Snowflake qui doivent exister avant le premier lancement (tables `DQ_*`, referentiel `SIRENE_SIEGES`, service de recherche vectorielle `SIRENE_COMPANY_SEARCH`, vue semantique `SV_QUALITIX`).

Les scripts de creation, numerotes dans l'ordre d'execution, sont dans [snowflake_setup/](snowflake_setup/). Le mode d'emploi et les points d'attention sont dans [snowflake_setup/SNOWFLAKE_SETUP_DDL.md](snowflake_setup/SNOWFLAKE_SETUP_DDL.md).

---

## Lancer l'application

```bash
pip install -r requirements.txt
streamlit run app.py
```

Accessible sur http://localhost:8501

---

## Guide demo (pas a pas)

### 1. Installation (une seule fois)

1. Installer **Python 3.10 a 3.12** depuis python.org (Windows : cocher *Add Python to PATH*).
2. Recuperer le code :
   ```bash
   git clone https://github.com/HazourliTasnim/leon-data-quality-repo.git
   cd leon-data-quality-repo
   ```
3. Creer un environnement et installer les dependances :
   ```bash
   python -m venv .venv
   .venv\Scripts\activate          # Windows (Mac/Linux : source .venv/bin/activate)
   pip install -r requirements.txt
   ```
   > Windows : si `python` n'est pas reconnu, utiliser `py` (ex. `py -m pip install -r requirements.txt`).
   > Si PowerShell bloque l'activation : `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

Aucun script `snowflake_setup/` a lancer : les objets existent deja sur le compte de demo.

### 2. Avant la demo

1. Mettre a jour le code : `git pull`
2. Lancer l'app : `streamlit run app.py` (ou `py -m streamlit run app.py`), puis ouvrir http://localhost:8501
3. Se connecter sur l'ecran de connexion :
   - **Compte** : `SFSEEUROPE-TEST_DEMO_ACCOUNT_AS`
   - **Utilisateur** : `LEON_DEMO` (mot de passe communique separement)
   - **MFA** : le code est envoye sur l'appareil enregistre pour `LEON_DEMO` ; prevoir la personne qui le detient, ou un contournement temporaire par un admin (`ALTER USER LEON_DEMO SET MINS_TO_BYPASS_MFA = 240;`)
4. Faire un essai complet avec `input/fichier_test_1.xlsx` pour verifier que tout repond (connexion, Cortex, export).

### 3. Deroule de la demo

1. **Tableau de bord** : presenter les KPIs (score de conformite, anomalies, completude).
2. **Lancer l'analyse** :
   1. *Selection des sujets* : choisir les controles (conformite, doublons...).
   2. *Perimetre* : importer le fichier (ex. `input/fichier_test_1.xlsx`), verifier la **correspondance des colonnes** (detection automatique par IA), puis *Valider et continuer*.
   3. *Data Cleaning* : choisir les colonnes de detection (bouton **Tout selectionner** disponible), puis *Demarrer le nettoyage* (doublons exacts, corrections, similarite).
   4. *Execution* : application des regles et rapprochement INSEE SIRENE.
   5. *Resultats* : lignes analysees, anomalies par severite, doublons supprimes, score de conformite.
3. **Anomalies** : filtrer par severite / statut, montrer la verification web (Agent IA).
4. **Taches** : accepter / corriger / rejeter en masse.
5. **Catalogue de regles** : montrer l'import de regles metier en langage naturel (`input/regles_metier_test.txt`).
6. **Exports** : telecharger le rapport (colonnes originales et corrigees cote a cote).



## Architecture

```
app.py                  # Application principale (Streamlit)
requirements.txt        # Dependances Python
snowflake.yml           # Configuration Snowflake CLI
.streamlit/
  config.toml           # Configuration Streamlit (theme, port)
  secrets.toml          # Optionnel, non committe (voir "Connexion Snowflake")
input/                  # Fichiers de donnees pour import
snowflake_setup/        # Scripts SQL de creation des objets Snowflake (tables, Cortex Search)
```

---

## Fonctionnalites

- **Tableau de bord** : KPIs temps reel (score conformite, anomalies, completude)
- **Donnees clients** : exploration et recherche du portefeuille B2B
- **Catalogue de regles** : regles preconfigurees + import via fichier texte (IA)
- **Lancer l'analyse** : wizard 5 etapes (selection sujets, perimetre, nettoyage, execution, resultats)
- **Anomalies** : liste detaillee avec filtres severite/statut, verification web (Agent IA)
- **Taches** : file de validation (accepter/corriger/rejeter en masse)
- **Exports** : CSV enrichi avec colonnes originales + corrigees cote a cote

---

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Frontend | Streamlit |
| Backend | Snowflake (SQL, Cortex AI) |
| IA | Cortex Complete (mistral-large2) |
| Recherche semantique | Cortex Search Service (snowflake-arctic-embed-l-v2.0) |
| Referentiel | INSEE SIRENE (29M+ etablissements) |
| Base vectorisee | SIRENE_COMPANY_SEARCH (~13M sieges, embeddings) |
| Verification web | Pappers API + Google + LLM |

---

## Connexion Snowflake

- **Identifiants** : saisis sur l'ecran de connexion de l'app (compte, utilisateur, mot de passe + code MFA, ou SSO navigateur). Aucun identifiant n'est lu depuis un fichier.
- **`.streamlit/secrets.toml`** : optionnel. Seule la cle `[connections.snowflake] account` est lue, en secours, par l'assistant Cortex Analyst si la connexion ne fournit pas le nom du compte.
- **Database** : `QUALITY_TEST`
- **Schema** : `COMMERCIAL_DATA` (donnees), `DATA_QUALITY` (DQ engine)
- **Warehouse** : `COMPUTE_WH`
- **Cortex Search Service** : `QUALITY_TEST.DATA_QUALITY.SIRENE_COMPANY_SEARCH`
  - ~13M sieges d'entreprises indexes avec `snowflake-arctic-embed-l-v2.0`
  - Utilise pour le matching semantique par nom d'entreprise (remplace JAROWINKLER)

---

## Import de regles metier

L'application permet d'uploader un fichier texte (.txt, .pdf, .docx) decrivant des regles en langage naturel. Cortex AI les convertit automatiquement en regles executables (regex, not_empty, in_list, length).

---

## Auteurs

## Architecture IA

L'application utilise 8 appels Cortex AI :

1. **Mapping de colonnes** : detection automatique des colonnes importees (Cortex Complete)
2. **Import de regles** : extraction de regles metier depuis fichiers texte (Cortex Complete)
3. **Auto-correction** : deduction SIREN/TVA + correction assistee (Cortex Complete)
4. **Jugement web** : verification d'anomalies via sources publiques (Cortex Complete)
5. **Suggestion de regles** : proposition de regles pour une table (Cortex Complete)
6. **Enrichissement SIRENE** : cle de jointure suggeree par IA (Cortex Complete)
7. **Cle de jointure** : suggestion de JOIN entre tables (Cortex Complete)
8. **Recherche SIRENE par nom** : matching semantique via Cortex Search Service (arctic-embed-l-v2.0)

---

Projet realise par l'equipe Data Quality - Snowflake SE.
