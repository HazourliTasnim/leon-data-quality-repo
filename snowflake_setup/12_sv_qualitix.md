# SV_QUALITIX — Vue sémantique Cortex Analyst

`QUALITY_TEST.DATA_QUALITY.SV_QUALITIX` 


## Objectif

Cette vue sémantique permet à Cortex Analyst de répondre en langage naturel aux questions sur la qualité des données B2B du projet Qualitix. Elle expose les anomalies détectées et les comptes impactés via un modèle dimensionnel simple (2 tables, 9 dimensions, 4 métriques).

## Tables sources

| Table logique | Table physique | Schema | Description |
|---|---|---|---|
| `ACCOUNTS` | `DIM_ACCOUNT` | `COMMERCIAL_DATA` | Référentiel des comptes entreprises B2B (PK : `ACCOUNT_ID`) |
| `FINDINGS` | `DQ_FINDINGS` | `DATA_QUALITY` | Anomalies détectées par les règles de qualité (PK : `ID`) |

## Relations

```
FINDINGS.ACCOUNT_ID  ──FK──>  ACCOUNTS.ACCOUNT_ID
```

Chaque anomalie (finding) est rattachée à un compte entreprise.

## Dimensions

| Nom logique | Table | Expression | Type | Synonymes | Description |
|---|---|---|---|---|---|
| `COUNTRY_DIM` | ACCOUNTS | `COUNTRY` | VARCHAR(10) | — | Code pays |
| `NAF_DIM` | ACCOUNTS | `NAF` | VARCHAR(10) | — | Code NAF activité |
| `COMPANY_DIM` | FINDINGS | `COMPANY_NAME` | VARCHAR(255) | entreprise, societe | Nom entreprise concernée |
| `CREATED_DATE` | FINDINGS | `CREATED_AT` | TIMESTAMP_NTZ | — | Date détection anomalie |
| `FIELD_DIM` | FINDINGS | `FIELD_LABEL` | VARCHAR(100) | champ, colonne | Champ en erreur |
| `FINDING_TYPE_DIM` | FINDINGS | `FINDING_TYPE` | VARCHAR(255) | — | Type d'anomalie |
| `RULE_ID_DIM` | FINDINGS | `RULE_ID` | VARCHAR(10) | regle, code regle | ID de la règle (R01–R08) |
| `SEVERITY_DIM` | FINDINGS | `SEVERITY` | VARCHAR(10) | severite, gravite | Sévérité : HIGH, MEDIUM, LOW |
| `STATUS_DIM` | FINDINGS | `STATUS` | VARCHAR(20) | statut | Statut : Open, In Review, Resolved, Dismissed |

Les dimensions `SEVERITY_DIM` et `STATUS_DIM` sont déclarées comme enums avec des `SAMPLE_VALUES` pour guider l'IA sur les valeurs possibles.

## Métriques

| Nom logique | Table | Expression SQL | Description |
|---|---|---|---|
| `TOTAL_ANOMALIES` | FINDINGS | `COUNT(ID)` | Total anomalies détectées |
| `OPEN_ANOMALIES` | FINDINGS | `COUNT(CASE WHEN STATUS = 'Open' THEN 1 END)` | Anomalies ouvertes non traitées |
| `HIGH_SEVERITY` | FINDINGS | `COUNT(CASE WHEN SEVERITY = 'HIGH' THEN 1 END)` | Anomalies critiques |
| `AFFECTED_ACCOUNTS` | FINDINGS | `COUNT(DISTINCT ACCOUNT_ID)` | Comptes distincts impactés |

Synonymes déclarés pour `TOTAL_ANOMALIES` : nombre anomalies, combien erreurs.

## Exemples de questions supportées

Grâce aux synonymes et enums, Cortex Analyst peut répondre à des questions comme :

- « Combien d'anomalies ouvertes ? » → `OPEN_ANOMALIES`
- « Quelles entreprises ont le plus d'erreurs critiques ? » → `HIGH_SEVERITY` groupé par `COMPANY_DIM`
- « Évolution des anomalies par mois ? » → `TOTAL_ANOMALIES` groupé par `CREATED_DATE`
- « Quels champs sont les plus souvent en erreur ? » → `TOTAL_ANOMALIES` groupé par `FIELD_DIM`
- « Combien de comptes impactés par sévérité ? » → `AFFECTED_ACCOUNTS` groupé par `SEVERITY_DIM`

## Dépendances

```
DIM_ACCOUNT (00_dim_account.sql)
    └── SV_QUALITIX (12_sv_qualitix.sql)
DQ_FINDINGS (03_dq_findings.sql)
    └── SV_QUALITIX (12_sv_qualitix.sql)
```

Les deux tables physiques doivent exister et contenir des données avant que la vue sémantique soit exploitable par Cortex Analyst.
