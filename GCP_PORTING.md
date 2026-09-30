# Leon — Portage Snowflake → GCP

Ce document explique comment Leon dépend aujourd'hui de Snowflake et liste les points d'attention pour un portage. Il distingue le code qui se reprend tel quel de celui qui est lié à Snowflake. Il part du principe que le lecteur ne connaît pas encore le code.

Documents associés :
- [README.md](README.md) : présentation et lancement
- [CODE_STRUCTURE.md](CODE_STRUCTURE.md) : architecture de `app.py`, section par section
- [snowflake_setup/SNOWFLAKE_SETUP_DDL.md](snowflake_setup/SNOWFLAKE_SETUP_DDL.md) : définition de tous les objets Snowflake (tables, recherche vectorielle, vue sémantique)

Numéros de ligne vérifiés le 2026-09-30 sur `app.py` (11 254 lignes). Ils dérivent à chaque modification : se fier aux noms de fonctions.

---

## 1. Leon en une phrase

Une application Streamlit de qualité de données clients B2B : import d'un fichier ou lecture d'une table → détection des colonnes → règles de validation (SIREN, SIRET, TVA, NAF…) → rapprochement avec le registre INSEE SIRENE → dédoublonnage → corrections assistées par IA → historisation. Tout le code est dans un seul fichier, [app.py](app.py).

---

## 2. Code sans dépendance Snowflake

- Les règles de validation R01–R08 : regex Python (`_valid_siren`, `_valid_siret`, `_valid_vat_fr`, `_valid_naf`, [app.py:3280-3325](app.py#L3280-L3325))
- Le moteur d'analyse des fichiers importés, `analyze_uploaded_dataframe()` ([app.py:3506](app.py#L3506)), en dehors de ses appels SIRENE
- Le dédoublonnage en mémoire : 3 phases pandas + `difflib` ([app.py:1124-1456](app.py#L1124-L1456))
- Le scoring, le nettoyage pandas, l'export Excel (`openpyxl`)
- Toute l'interface Streamlit et la gestion du `session_state`
- La vérification web ([app.py:900](app.py#L900)) : appels `requests` vers Pappers, societe.com et Google. Elle a besoin d'un accès Internet sortant depuis l'environnement d'exécution (sur Snowflake, cela exige une External Access Integration).

---

## 3. Les points de couplage Snowflake

### 3.1 Connexion et exécution SQL — [app.py:248-313](app.py#L248-L313)

Presque tout le SQL passe par deux fonctions pivots :
- `_sf_query(sql)` → DataFrame (47 appels)
- `_sf_execute(sql, params)` → bool (16 appels)

Points d'attention :
- **Paramètres liés** : `_sf_execute` utilise le style `%(name)s` du connecteur Snowflake (16 appels).
- **Accès directs au connecteur**, hors des deux fonctions pivots :
  - [app.py:491](app.py#L491) : mise à jour des anomalies par lots (`update_findings_status_batch`)
  - [app.py:1573-1595](app.py#L1573-L1595) : `USE DATABASE` / `USE SCHEMA` et création de table dans `stage_dataframe_to_snowflake`
  - [app.py:11177](app.py#L11177) : test de connexion `SELECT 1` au login
- **Erreurs masquées** : `_sf_query` et `_sf_execute` avalent les exceptions et renvoient un DataFrame vide ou `False`. Une requête invalide passe donc inaperçue, ce qui rendra les erreurs du portage difficiles à repérer.
- **Requêtes construites par concaténation** (f-strings) avec un échappement manuel des `'` : risque d'injection SQL.

### 3.2 Authentification — [app.py:10951](app.py#L10951) (`page_login`)

L'utilisateur saisit compte / utilisateur / mot de passe + code MFA, ou choisit le SSO navigateur (`externalbrowser`). Rien n'est lu depuis un fichier. La connexion est mise en cache par Streamlit (`@st.cache_resource`) et réutilisée pour toutes les requêtes.

Point d'attention : l'écran contient des valeurs par défaut propres au compte Snowflake de démo ([app.py:11125-11129](app.py#L11125-L11129)).

### 3.3 IA générative — Cortex Complete (10 appels)

```python
_sf_query(f"SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $${prompt}$$) AS r")
```

Le LLM (`mistral-large2`) est appelé via une requête SQL. Usages : mapping des colonnes, import de règles depuis un fichier texte, suggestion de règles et de clé de jointure, auto-correction, avis sur la vérification web, dédoublonnage et fusion par IA.

Points d'attention :
- **Appels non centralisés** : chaque appel construit sa propre requête : [707](app.py#L707), [734](app.py#L734), [1048](app.py#L1048), [3184](app.py#L3184), [6377](app.py#L6377), [6805](app.py#L6805), [9105](app.py#L9105), [9613](app.py#L9613), [9829](app.py#L9829), [9903](app.py#L9903).
- **Échappement lié au SQL** : les prompts sont entourés de `$$ ... $$` ou passés par `.replace("'", "''")`.
- **Réponses JSON attendues** : plusieurs prompts demandent du JSON et le code le parse. Le format de réponse dépend du modèle ; un changement de modèle peut casser ce parsing.
- **Limite de taille** : le dédoublonnage par IA découpe les données par lots de 200 enregistrements ([app.py:9806](app.py#L9806)) à cause des limites de tokens de `mistral-large2`.

### 3.4 Recherche vectorielle — Cortex Search

C'est la base vectorielle du projet. Code : `_cortex_search_sirene()` ([app.py:3348](app.py#L3348)), appelée par `_insee_search_by_name()` ([app.py:3390](app.py#L3390)) et par le moteur d'analyse ([app.py:3585-3640](app.py#L3585-L3640)).

Fonctionnement actuel (définition : [02_sirene_company_search.sql](snowflake_setup/02_sirene_company_search.sql)) :
- Service `SIRENE_COMPANY_SEARCH` sur la table `SIRENE_SIEGES`, ~12,9 M lignes indexées (les entreprises sans dénomination sont exclues)
- Texte indexé : `DENOMINATION || ' ' || VILLE`
- Modèle d'embeddings : `snowflake-arctic-embed-l-v2.0`, index rafraîchi chaque jour (`TARGET_LAG = '1 day'`)
- Appel via la fonction SQL `SNOWFLAKE.CORTEX.SEARCH_PREVIEW`, avec la requête « nom de l'entreprise + ville », un filtre `STATUT = 'A'` (entreprises actives) et 3 à 5 résultats
- Résultats mis en cache 5 minutes (`@st.cache_data`)
- Solution de repli si le service ne répond pas : similarité `EDITDISTANCE` + `SOUNDEX` en SQL sur le registre SIRENE ([app.py:3423](app.py#L3423))

Points d'attention :
- **Volume** : les embeddings des ~12,9 M lignes sont calculés et maintenus par Snowflake. Sans ce service, ils sont à recalculer en totalité.
- **Seuil de 0,35** : un résultat est accepté si sa similarité cosinus est ≥ 0,35. Cette valeur est propre au modèle Arctic et n'a pas de sens pour un autre modèle.
- **Reranking** : Cortex Search renvoie aussi un score de reranking, que le code lit (`reranker_score`) pour classer les résultats.
- **Rafraîchissement** : l'index suit automatiquement les mises à jour de `SIRENE_SIEGES`.
- **Un appel par nom d'entreprise** : pour un fichier sans SIREN, le moteur d'analyse fait un appel par nom unique ([app.py:3611](app.py#L3611)). La latence de la recherche pèse directement sur la durée d'une analyse.

### 3.5 Référentiel INSEE SIRENE — Marketplace Snowflake — [app.py:229-232](app.py#L229-L232)

```python
_SIRENE_DB = "FRENCH_NATIONAL_IDENTIFICATION_SYSTEM_OF_DIRECTORY_OF_BUSINESSES_AND_THEIR_ESTABLISHMENTS"
_SIRENE_UL   = f"{_SIRENE_DB}.SIRENE.V_UNITE_LEGALE"     # ~29,6 M lignes
_SIRENE_ETAB = f"{_SIRENE_DB}.SIRENE.V_ETABLISSEMENT"
```

S'y ajoute la table préparée `QUALITY_TEST.DATA_QUALITY.SIRENE_SIEGES` (une ligne par SIREN, [app.py:3564](app.py#L3564)), qui alimente aussi la recherche vectorielle.

Points d'attention :
- **Pas de chargement de notre côté** : sur Snowflake, ces données sont partagées par le fournisseur du Marketplace et mises à jour par lui. Hors Snowflake, il n'y a ni données ni mises à jour.
- **Vérification par lots** : le moteur d'analyse interroge le registre par lots de 500 SIREN ([app.py:3563](app.py#L3563)).
- **Requête de construction de `SIRENE_SIEGES` non documentée** : voir [snowflake_setup/SNOWFLAKE_SETUP_DDL.md](snowflake_setup/SNOWFLAKE_SETUP_DDL.md).

### 3.6 Assistant conversationnel — Cortex Analyst — [app.py:10779-10947](app.py#L10779-L10947)

Le chat flottant appelle l'API REST Cortex Analyst (`/api/v2/cortex/analyst/message`) avec le jeton de session du connecteur (`conn.rest.token`, [app.py:10790](app.py#L10790)) et la vue sémantique `SV_QUALITIX`. Celle-ci décrit 2 tables, 9 dimensions, 4 métriques et leurs synonymes en français : voir [12_sv_qualitix.md](snowflake_setup/12_sv_qualitix.md).

Point d'attention : fonctionnalité indépendante du reste de l'application. Si elle ne fonctionne pas, seul le chat est touché.

### 3.7 Écriture en masse — `write_pandas` — [app.py:1557-1619](app.py#L1557-L1619)

`stage_dataframe_to_snowflake()` charge un DataFrame importé dans `DQ_STAGING_IMPORT` avec `write_pandas` (fonction du connecteur Snowflake), avec un repli par `INSERT` paramétrés.

### 3.8 Métadonnées — `SHOW` / `INFORMATION_SCHEMA` — [app.py:682-833](app.py#L682-L833)

`SHOW DATABASES`, `SHOW SCHEMAS`, `SHOW TABLES`, `SHOW COLUMNS` et `INFORMATION_SCHEMA.COLUMNS` servent à lister les sources disponibles dans l'interface. La hiérarchie base → schéma → table est propre à Snowflake.

### 3.9 Syntaxe SQL propre à Snowflake

| Syntaxe | Où |
|---|---|
| `DATEADD('day', -n, CURRENT_DATE())` | [429](app.py#L429), [5550](app.py#L5550) |
| Cast `expr::FLOAT` | [5546](app.py#L5546) |
| `CREATE OR REPLACE TRANSIENT TABLE ... AS` | [1531](app.py#L1531) |
| `EDITDISTANCE`, `SOUNDEX` | [3423](app.py#L3423) |
| `UUID_STRING()`, `TIMESTAMP_NTZ` | [537-550](app.py#L537-L550) |
| `USE DATABASE` / `USE SCHEMA` | [1573](app.py#L1573) |
| Chaînes `$$ ... $$` | appels Cortex (§3.3) |

Pour les types de colonnes des tables (`VARIANT`, `AUTOINCREMENT`, `NUMBER`…), voir [SNOWFLAKE_SETUP_DDL.md](snowflake_setup/SNOWFLAKE_SETUP_DDL.md).

**Noms d'objets écrits en dur** : `QUALITY_TEST.DATA_QUALITY.*` et `QUALITY_TEST.COMMERCIAL_DATA.*` apparaissent dans tout le fichier, sans configuration centralisée.

---

## 4. Hébergement actuel

Streamlit-in-Snowflake, déployé via [snowflake.yml](snowflake.yml), ou lancé en local avec `streamlit run app.py`.

---

## 5. Hors périmètre

- **`SP_EXECUTE_BUSINESS_RULES`** (procédure stockée, [app.py:518](app.py#L518)) : appelée uniquement depuis l'ancien module France, qui n'est plus affiché.
- **`DQ_SESSION_CACHE`** : table présente dans Snowflake mais inutilisée par le code.
