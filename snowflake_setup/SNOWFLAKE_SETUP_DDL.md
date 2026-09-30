# Définitions SQL — Objets Snowflake du projet Qualitix

Définitions extraites depuis Snowflake le 2026-09-30.

Tous les objets vivent dans `QUALITY_TEST.DATA_QUALITY`, sauf `DIM_ACCOUNT` qui est dans `QUALITY_TEST.COMMERCIAL_DATA`.

## Ordre d'exécution

Les scripts sont numérotés dans l'ordre de dépendance :

| # | Fichier | Objet | Type |
|---|---------|-------|------|
| 00 | [00_dim_account.sql](00_dim_account.sql) | `DIM_ACCOUNT` | TABLE (`COMMERCIAL_DATA`) — référentiel comptes B2B, PK `ACCOUNT_ID`, référencée par `SV_QUALITIX` |
| 01 | [01_sirene_sieges.sql](01_sirene_sieges.sql) | `SIRENE_SIEGES` | TABLE — référentiel SIRENE, 1 ligne/SIREN (~29.6M) |
| 02 | [02_sirene_company_search.sql](02_sirene_company_search.sql) | `SIRENE_COMPANY_SEARCH` | CORTEX SEARCH SERVICE — recherche vectorielle sur `SIRENE_SIEGES` |
| 03 | [03_dq_findings.sql](03_dq_findings.sql) | `DQ_FINDINGS` | TABLE — anomalies détectées |
| 04 | [04_dq_corrections.sql](04_dq_corrections.sql) | `DQ_CORRECTIONS` | TABLE — corrections appliquées/rejetées |
| 05 | [05_dq_analysis_history.sql](05_dq_analysis_history.sql) | `DQ_ANALYSIS_HISTORY` | TABLE — historique des runs d'analyse |
| 06 | [06_dq_audit_log.sql](06_dq_audit_log.sql) | `DQ_AUDIT_LOG` | TABLE — journal d'audit |
| 07 | [07_dq_session_cache.sql](07_dq_session_cache.sql) | `DQ_SESSION_CACHE` | TABLE — cache de session (VARIANT) |
| 08 | [08_dq_custom_rules.sql](08_dq_custom_rules.sql) | `DQ_CUSTOM_RULES` | TABLE — règles de validation custom |
| 09 | [09_dq_dedup_results.sql](09_dq_dedup_results.sql) | `DQ_DEDUP_RESULTS` | TABLE — résultats de dédoublonnage |
| 10 | [10_dq_scoring.sql](10_dq_scoring.sql) | `DQ_SCORING` | TABLE — scores qualité par ligne |
| 11 | [11_dq_staging_import_clean.sql](11_dq_staging_import_clean.sql) | `DQ_STAGING_IMPORT_CLEAN` | TABLE TRANSIENT — staging import |
| 12 | [12_sv_qualitix.sql](12_sv_qualitix.sql) | `SV_QUALITIX` | SEMANTIC VIEW — Cortex Analyst, 2 tables (ACCOUNTS + FINDINGS), 4 métriques, 9 dimensions — voir [12_sv_qualitix.md](12_sv_qualitix.md) |

## Prérequis

- La database `QUALITY_TEST` et les schemas `DATA_QUALITY` + `COMMERCIAL_DATA` doivent exister.
- `DIM_ACCOUNT` (00) et `DQ_FINDINGS` (03) doivent exister avant de créer `SV_QUALITIX` (12).
- Le search service (02) nécessite un warehouse `COMPUTE_WH` actif.
- La table `SIRENE_SIEGES` (01) doit être peuplée avant de créer le search service (02).
- Source des données SIRENE : listing Marketplace `FRENCH_NATIONAL_IDENTIFICATION_SYSTEM_OF_DIRECTORY_OF_BUSINESSES_AND_THEIR_ESTABLISHMENTS.SIRENE`.

## Points d'attention

- **Tous les scripts utilisent `CREATE OR REPLACE`** : les relancer sur un compte existant supprime les données en place. Pour une première installation uniquement.
- **`SIRENE_SIEGES` : structure seule, pas de chargement.** Le script 01 crée la table vide. La requête qui la remplit depuis le Marketplace SIRENE (`V_UNITE_LEGALE` + `V_ETABLISSEMENT`, filtrée sur les sièges) n'a pas été extraite et reste à documenter.
- **`SV_QUALITIX`** (12) est la vue sémantique utilisée par l'assistant de chat Cortex Analyst de l'app (`SEMANTIC_VIEW_FQN` dans `app.py`). Sans elle, le chat ne répond pas ; le reste de l'app fonctionne. Son script (12) a été **reconstruit à partir de la documentation**, pas extrait de Snowflake : à remplacer par la sortie de `GET_DDL('SEMANTIC_VIEW', ...)` si possible.
- **`DIM_ACCOUNT`** (00) est la table client lue par défaut quand l'utilisateur analyse une table Snowflake plutôt qu'un fichier importé (nom configurable à la connexion).
- **Table non utilisée par `app.py`** : `DQ_SESSION_CACHE` (07) existe dans le compte mais aucune requête de l'application actuelle ne la lit ni ne l'écrit. Probablement un vestige d'une ancienne version — à ne pas porter en priorité.
- **Tables de staging recréées par l'app** : `DQ_STAGING_IMPORT_CLEAN` (11) est recréée à chaque dédoublonnage (`CREATE OR REPLACE TRANSIENT TABLE ... AS SELECT` dans `deduplicate_snowflake_table()`), et `DQ_STAGING_IMPORT` est créée par `write_pandas` lors de l'import d'un fichier. Le script 11 n'est donc pas indispensable.
- **`DQ_ANALYSIS_HISTORY`** est aussi créée automatiquement par l'app au premier run (`CREATE TABLE IF NOT EXISTS` dans `_ensure_history_table()`).

## Correspondance pour un portage GCP / BigQuery

| Snowflake | Équivalent BigQuery |
|-----------|---------------------|
| `VARCHAR(n)` | `STRING` |
| `NUMBER(38,0)` | `INT64` (ou `NUMERIC`) |
| `NUMBER(5,2)` / `NUMBER(3,2)` | `NUMERIC(5,2)` / `NUMERIC(3,2)` |
| `FLOAT` | `FLOAT64` |
| `TIMESTAMP_NTZ` | `DATETIME` |
| `VARIANT` | `JSON` |
| `UUID_STRING()` | `GENERATE_UUID()` |
| `AUTOINCREMENT` | pas d'équivalent — générer l'ID côté app (`GENERATE_UUID()`) |
| `PRIMARY KEY` | `PRIMARY KEY (...) NOT ENFORCED` (informatif uniquement) |
| `DEFAULT CURRENT_USER()` | pas d'équivalent en `DEFAULT` — renseigner côté app |
| `TRANSIENT TABLE` | table standard avec expiration (`OPTIONS(expiration_timestamp=...)`) |
| `CORTEX SEARCH SERVICE` | Vertex AI Vector Search, ou table d'embeddings BigQuery + `VECTOR_SEARCH()` (embeddings via Vertex AI `text-multilingual-embedding`) |
