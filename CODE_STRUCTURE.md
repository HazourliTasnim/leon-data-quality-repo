# Leon — Code Review & Architecture Technique

## 1. C'est quoi Leon ?

Leon est une plateforme de **qualite de donnees B2B**. Elle prend en entree un fichier client (CSV/Excel) ou une table Snowflake, et :

1. Detecte automatiquement les colonnes (SIREN, raison sociale, TVA, etc.)
2. Applique des regles de validation (format, coherence, conformite)
3. Cross-check contre le registre INSEE officiel
4. Detecte les doublons (exact + fuzzy matching)
5. Propose des corrections automatiques (depuis INSEE)
6. Historise chaque run d'analyse

**Pour qui ?** Equipes data / commercial qui gerent des bases clients B2B en France.

---

## 2. Stack technique — Pourquoi ces choix ?

| Composant | Technologie | Pourquoi |
|-----------|-------------|----------|
| UI | Streamlit | Prototype rapide, pas de frontend separe, natif Python |
| Backend | Python (pandas) | Manipulation dataframe, regles metier en Python pur |
| Database | Snowflake | Cloud-native, marketplace INSEE integree, Cortex AI, Cortex Search |
| IA | Cortex `mistral-large2` | Detection colonnes, detection regles depuis fichiers texte |
| Recherche semantique | Cortex Search Service | ~13M sieges indexes avec `arctic-embed-l-v2.0` |
| Registre | INSEE SIRENE (Marketplace) | Source officielle, 29M+ entreprises, gratuite via Marketplace |

**Tout est dans un seul fichier (`app.py`)** — c'est un choix delibere pour un prototype/MVP. En production on decouperiait en modules.

---

## 3. Langages utilises dans le projet

### Python — Logique metier & UI

- **Regles de validation** (R01-R08) : expressions regulieres Python (`re.match`)
- **Nettoyage de donnees** : pandas (vectorisation avec `.str`, masques booleens)
- **Detection de doublons** : `difflib.SequenceMatcher` pour la similarite textuelle
- **UI** : Streamlit widgets + HTML/CSS inline pour le design personnalise
- **Orchestration** : session_state de Streamlit pour gerer le flux wizard multi-etapes

### SQL — Acces aux donnees Snowflake

- **Lecture de tables** : `SELECT * FROM table` via `_sf_query()`
- **Lookup INSEE** : requetes SQL sur `V_UNITE_LEGALE` (29M lignes) avec filtres
- **Recherche semantique** : `SNOWFLAKE.CORTEX.SEARCH_PREVIEW()` via le Cortex Search Service `SIRENE_COMPANY_SEARCH`
- **Persistance** : `INSERT INTO` pour sauvegarder anomalies, corrections, historique
- **Cortex AI** : `SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', prompt)` — appel IA via SQL
- **DDL** : `CREATE TABLE IF NOT EXISTS` pour les tables de metadonnees

### Pas de SQL pour les regles de validation

Les regles (format SIREN, coherence SIRET, TVA) sont en **Python pur**. Pourquoi ?
- On travaille sur un DataFrame pandas en memoire (pas directement sur la table Snowflake)
- Le fichier uploade est lu localement — pas besoin de SQL pour ca
- Les regles sont des regex/conditions Python — plus simples a ecrire et debugger qu'en SQL
- Le cross-check INSEE est la seule partie qui utilise SQL (car les donnees sont dans Snowflake)

---

## 4. Architecture du code (sections)

```
app.py
│
├── [L1-245]     CONSTANTES & CONFIGURATION
│                 - Themes (dark/light), pages, aliases colonnes
│                 - Templates de regles, sujets d'analyse
│
├── [L246-627]   DATA LAYER (SQL/Snowflake)
│                 - Connexion, requetes, cache (_get_conn, _sf_query, _sf_execute)
│                 - Lectures DQ_*, lookup SIRENE, historique des analyses
│
├── [L628-854]   HELPERS (CRUD regles, tables, Cortex)
│                 - Gestion des regles custom
│                 - Suggestions Cortex AI (cle de jointure, regles)
│
├── [L855-1076]  CORRECTIONS & VERIFICATION
│                 - Appliquer une correction depuis INSEE
│                 - Verification web (Pappers, Google, Cortex AI)
│
├── [L1077-1619] PIPELINE DEDUPLICATION
│                 - 3 phases : exact, format, similarite
│                 - Dedup SQL + staging (DQ_STAGING_IMPORT, write_pandas)
│
├── [L1620-1715] MOTEUR DE REGLES (tables Snowflake)
│                 - run_snowflake_dq_analysis()
│
├── [L1716-3084] UI HELPERS & STYLING
│                 - CSS global, composants reutilisables, badges, KPI
│
├── [L3085-3505] IMPORT & DETECTION COLONNES + SIRENE
│                 - detect_column_mapping() : alias matching
│                 - detect_column_mapping_ai() : Cortex AI
│                 - Validateurs SIREN/SIRET/TVA/NAF
│                 - _cortex_search_sirene() : recherche vectorielle (L3348)
│
├── [L3506-4139] MOTEUR D'ANALYSE PRINCIPAL
│                 - analyze_uploaded_dataframe() — LE COEUR
│
├── [L4140-4305] UTILITAIRES SESSION
│                 - Gestion session_state, SLA, stockage des resultats
│
├── [L4306-10778] PAGES (UI)
│                 - Sidebar, Dashboard, Donnees clients, Analyse, Anomalies,
│                   Taches, Exports, Enrichissement SIRENE, Historique, Catalogue
│
├── [L10779-10947] CHATBOX (Cortex Analyst, vue semantique SV_QUALITIX)
│
└── [L10948-11254] LOGIN & MAIN
```

> Numeros de ligne verifies le 2026-09-30 (app.py = 11 254 lignes). Ils derivent a chaque modification : se fier aux noms de fonctions.

---

## 5. Flux principal — De l'upload au resultat

```
                    UPLOAD FICHIER (.csv/.xlsx)
                              │
                              ▼
                   pandas.read_csv / read_excel
                              │
                              ▼
              ┌───────────────────────────────┐
              │  STEP 1: Detection colonnes   │
              │                               │
              │  1. COLUMN_ALIASES (Python)    │
              │     → match exact/contient    │
              │                               │
              │  2. Cortex AI (SQL→LLM)       │
              │     → si alias n'a rien       │
              │       trouvé, demande au LLM  │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  STEP 2: Mapping colonnes     │
              │                               │
              │  L'utilisateur valide ou      │
              │  corrige les associations     │
              │  detectees automatiquement    │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  STEP 3: Regles               │
              │                               │
              │  Affiche les regles actives   │
              │  (R01-R08 + custom)           │
              │  L'utilisateur peut ajouter   │
              │  des regles manuellement      │
              │  ou uploader un fichier       │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  STEP 4: ANALYSE              │
              │  analyze_uploaded_dataframe()  │
              │                               │
              │  → Detaille ci-dessous        │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  STEP 5: Resultats            │
              │                               │
              │  Score, KPIs, anomalies       │
              │  Sauvegarde dans Snowflake    │
              └───────────────────────────────┘
```

---

## 6. Le moteur d'analyse — En detail

**Fonction :** `analyze_uploaded_dataframe()` (~630 lignes, L3506)

C'est la fonction la plus importante du projet. Voici ce qu'elle fait :

### Etape 1 : Pre-chargement batch INSEE (SQL)

```python
# On recupere TOUS les SIRENs du fichier
sirens_in_file = df["siren"].dropna().unique()

# UNE SEULE requete SQL pour recuperer les infos INSEE de tous ces SIRENs
sql = f"""
  SELECT SIREN, DENOMINATIONUNITELEGALE, ACTIVITEPRINCIPALEETABLISSEMENT, ...
  FROM {_SIRENE_UL}
  WHERE SIREN IN ({','.join(quoted_sirens)})
"""
sirene_cache = _sf_query(sql)  # → DataFrame avec les infos officielles
```

**Pourquoi batch ?** — Avant, on faisait 1 requete par ligne (lent). Maintenant 1 seule requete pour tout le fichier.

### Etape 2 : Recherche par nom (Cortex Search — embeddings semantiques)

Pour les lignes sans SIREN, on cherche par nom via le Cortex Search Service :

```python
# Appel au service de recherche vectorisee (~13M sieges)
results = _cortex_search_sirene("NOM CLIENT ville", limit=3, filter_obj={"@eq": {"STATUT": "A"}})
# → retourne les meilleures correspondances avec score de similarite cosinus
```

Le Cortex Search Service `SIRENE_COMPANY_SEARCH` utilise le modele d'embedding `snowflake-arctic-embed-l-v2.0`.
Chaque denomination + ville a ete vectorisee. La recherche est semantique : "Cie Generale" matchera
"COMPAGNIE GENERALE" car les embeddings capturent la similarite de sens, pas juste les caracteres.

Seuil d'acceptation : cosine similarity >= 0.35. Fallback vers EDITDISTANCE+SOUNDEX si le service est indisponible.

### Etape 3 : Vectorisation pandas (Python)

Avant la boucle, on prepare toutes les series nettoyees :

```python
_v_siren = df[mapping["siren"]].astype(str).str.strip()
_v_siret = df[mapping["siret"]].astype(str).str.strip()
_v_tva   = df[mapping["vat"]].astype(str).str.strip().str.upper()
# etc. pour chaque champ
```

**Pourquoi ?** — Acceder a `df["col"].iloc[i]` dans une boucle est lent. Pre-extraire les Series avec `.str.strip()` est beaucoup plus rapide.

### Etape 4 : Application des regles (Python)

Pour chaque ligne du fichier :

```python
for idx, row in df.iterrows():
    siren_val = _v_siren.iloc[idx]
    
    # R01: SIREN doit faire 9 chiffres
    if siren_val and not re.match(r'^\d{9}$', siren_val):
        anomalies.append({
            "rule_id": "R01",
            "field": "siren",
            "current_value": siren_val,
            "expected_value": sirene_official_siren,  # depuis le cache INSEE
            "severity": "critical"
        })
    
    # R04: TVA format (SEULEMENT pour les entreprises francaises)
    if _is_explicitly_fr[idx]:  # ← Garde-fou anti faux positifs
        tva_val = _v_tva.iloc[idx]
        if tva_val and not re.match(r'^FR\d{11}$', tva_val):
            ...
```

**Point cle : `_is_explicitly_fr`** — On ne signale un probleme de TVA que si l'entreprise est explicitement francaise (pays = FR ou pas de TVA etrangere). Sinon, une entreprise allemande avec TVA "DE123..." serait un faux positif.

### Etape 5 : Cross-check INSEE (Python, donnees SQL)

Si le SIREN est dans le cache INSEE, on compare :

```python
insee_record = sirene_cache_dict.get(siren_val)
if insee_record:
    # Le NAF officiel est different ?
    if insee_record["naf"] != naf_val:
        anomalies.append({
            "expected_value": insee_record["naf"],  # La VRAIE valeur INSEE
            ...
        })
```

**Important :** `expected_value` est TOUJOURS une valeur concrete venant d'INSEE — jamais un pattern regex, jamais une valeur calculee.

### Etape 6 : Regles custom (Python)

Les regles custom sont definies par l'utilisateur (ou importees d'un fichier). Types supportes :

| Type | Logique Python |
|------|---------------|
| `regex` | `re.match(pattern, value)` |
| `not_empty` | `value is not None and value != ""` |
| `in_list` | `value in allowed_values` |
| `length` | `len(value) == expected_length` |

---

## 7. Detection automatique des colonnes

Deux mecanismes, dans cet ordre :

### 1. Alias matching (Python pur) — `detect_column_mapping()`

```python
COLUMN_ALIASES = {
    "siren": ["siren", "num_siren", "no_siren", "idsiren", ...],
    "company_name": ["raison_sociale", "nom", "company", "entreprise", ...],
    "vat": ["vat", "tva", "vat_number", "num_tva", ...],
    ...
}
```

On normalise les noms de colonnes du fichier (lowercase, sans accents, sans espaces) et on compare avec les aliases connus.

### 2. Cortex AI (SQL → LLM) — `detect_column_mapping_ai()`

Si les alias ne matchent pas, on envoie la liste des colonnes au LLM :

```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $$
  Voici les colonnes du fichier: ["Col A", "Col B", ...]
  Associe-les aux champs attendus: siren, company_name, vat, ...
  Retourne un JSON.
$$)
```

Le LLM retourne un mapping JSON qui est ensuite valide (on verifie que chaque colonne retournee existe vraiment).

---

## 8. Pipeline de deduplication

3 phases progressives :

### Phase 1 — Doublons exacts (Python)

```python
# Meme SIREN = doublon exact
duplicates_siren = df.groupby("siren").filter(lambda x: len(x) > 1)

# Meme nom normalise = doublon exact
df["_norm_name"] = df["company_name"].str.lower().str.strip()
duplicates_name = df.groupby("_norm_name").filter(lambda x: len(x) > 1)
```

### Phase 2 — Erreurs de format (Python)

Detecte les quasi-doublons dus a des erreurs de saisie :
- SIREN a 8 chiffres (manque un zero)
- SIRET a 13 chiffres (manque un chiffre)
- Casse differente ("ACME" vs "Acme")

### Phase 3 — Similarite textuelle (Python)

```python
from difflib import SequenceMatcher

score = SequenceMatcher(None, nom_a, nom_b).ratio()
if score > 0.85:
    # Probable doublon
```

**Optimisation :** On ne compare pas toutes les paires (O(n²)) — on utilise un "blocking" par prefixe (premieres lettres) et par ville pour reduire les comparaisons.

**Verdicts :**
- `CONFIRME` → meme ville = doublon certain
- `A_VERIFIER` → ville inconnue = a confirmer manuellement

---

## 9. Corrections automatiques

Quand l'utilisateur clique "Corriger depuis INSEE" sur une anomalie :

```python
def _auto_correct_finding(finding):
    # On retourne DIRECTEMENT la valeur stockee dans expected_value
    # (qui vient du cache INSEE, cf section 6)
    return finding["expected_value"]
```

**Principe :** On ne recalcule rien. La correction = la valeur officielle INSEE qu'on a deja trouvee lors de l'analyse.

Ensuite :
1. `UPDATE DQ_FINDINGS SET status='resolved'` (SQL)
2. `INSERT INTO DQ_CORRECTIONS (...)` (SQL)
3. `INSERT INTO DQ_AUDIT_LOG (...)` (SQL)

---

## 10. Import intelligent de regles (Cortex AI)

L'utilisateur peut uploader un fichier texte/Word/PDF avec des regles metier en langage naturel.

**Avant :** parsing rigide qui attendait un format precis → 600+ regles poubelle.  
**Maintenant :** Cortex AI detecte les regles quel que soit le format.

```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $$
  Voici le contenu d'un fichier de regles metier:
  {contenu_fichier}
  
  Extrais les regles de qualite. Pour chaque regle, retourne:
  - name: nom court
  - description: ce que la regle verifie
  - field: le champ concerne (siren, company_name, vat, ...)
  - type: regex | not_empty | in_list | length
  - pattern: l'expression reguliere si applicable
  
  Retourne un JSON array.
$$)
```

Le LLM comprend le fichier quel que soit son format et extrait les regles structurees.

---

## 11. Persistance des donnees (SQL)

### Tables et leur role

| Table | Quand on ecrit | Quoi |
|-------|----------------|------|
| `DQ_FINDINGS` | Fin d'analyse (batch INSERT) | Chaque anomalie detectee |
| `DQ_CORRECTIONS` | Quand user clique "Corriger" | Ancien/nouveau valeur |
| `DQ_AUDIT_LOG` | Chaque action utilisateur | Qui, quoi, quand |
| `DQ_SCORING` | Fin d'analyse (batch INSERT par 50) | Score par ligne |
| `DQ_ANALYSIS_HISTORY` | Fin d'analyse (1 INSERT) | Resume du run |
| `DQ_CUSTOM_RULES` | Quand user cree/importe une regle | Definition de la regle |
| `DQ_DEDUP_RESULTS` | Fin dedup | Paires de doublons |

### Pattern d'ecriture SQL

```python
def persist_scoring(scores_list):
    """Insere les scores par batch de 50 (pas un INSERT par ligne)."""
    for batch in chunks(scores_list, 50):
        values = ",".join(f"('{s['siren']}', {s['score']})" for s in batch)
        _sf_execute(f"INSERT INTO DQ_SCORING VALUES {values}")
```

**Pourquoi batch de 50 ?** — Un INSERT par ligne = N allers-retours reseau. Batch = beaucoup plus rapide.

---

## 12. Gestion de l'etat (session_state Streamlit)

Streamlit re-execute TOUT le script a chaque interaction. Pour garder l'etat :

```python
# Wizard step (ou en est l'utilisateur)
st.session_state["import_wizard_step"]  # 1, 2, 3
st.session_state["wizard_step"]         # 1, 2, 3, 4, 5

# Donnees en cours
st.session_state["import_wizard_df"]       # DataFrame uploade
st.session_state["import_wizard_automap"]  # Mapping detecte
st.session_state["fr_upload_anomalies"]    # Anomalies trouvees
st.session_state["fr_upload_stats"]        # Statistiques du run

# Navigation
st.session_state["page"]  # "dashboard", "customer_data", "findings", ...
```

---

## 13. Cache & Performance

### @st.cache_data

```python
@st.cache_data(ttl=300)  # Cache 5 minutes
def load_dim_account(fqn):
    return _sf_query(f"SELECT * FROM {fqn}")
```

Streamlit memorise le resultat. Si la meme fonction est appelee avec les memes arguments dans les 5 minutes → pas de requete SQL, retourne le cache.

### Optimisations implementees

| Probleme | Solution |
|----------|----------|
| 1 requete SIRENE par ligne (lent) | Pre-load batch (1 requete pour tout le fichier) |
| JAROWINKLER insensible aux synonymes | Cortex Search Service (embeddings semantiques) |
| iterrows() lent avec `.iloc` | Vectorisation : pre-extraction des Series pandas |
| 1 INSERT par score (lent) | Batch INSERT par 50 |
| Cortex AI appele inutilement | Cache session_state (detect_column_mapping_ai) |

---

## 14. Securite & Limites

### Ce qui est bien
- Connexion Snowflake avec credentials (pas de token en dur)
- Validation des SIRENs (9 chiffres) avant injection en SQL
- Bulk corrections limitees (max 10) pour eviter les erreurs massives

### Ce qui pourrait etre ameliore
- **SQL par f-string** : `f"WHERE SIREN = '{siren}'"` au lieu de requetes parametrees
  - Risque faible car SIREN est valide (9 digits) mais pas ideal
- **Tout dans un fichier** : difficile a tester unitairement
- **Pas de pagination** : anomalies limitees a 200 lignes affichees
- **iterrows()** : O(n) Python, lent au-dessus de 5000 lignes (devrait etre 100% vectorise)

---

## 15. Calculs specifiques

### Calcul TVA depuis SIREN

```python
# Formule officielle francaise
tva = "FR" + str((12 + 3 * int(siren)) % 97).zfill(2) + siren
# Exemple: SIREN 443061841 → FR40443061841
```

Ce calcul n'est PAS utilise pour les corrections (on prend la valeur INSEE). Il sert uniquement a verifier la coherence.

### Score de qualite

```python
score = int((clean_rows / total_rows) * 100)
# clean_rows = lignes sans aucune anomalie
# total_rows = total de lignes dans le fichier
```

---

## 16. Resume des technologies par couche

```
┌─────────────────────────────────────────────────────┐
│  FRONTEND (UI)                                       │
│  → Streamlit widgets + HTML/CSS inline               │
│  → Session state pour l'etat                         │
├─────────────────────────────────────────────────────┤
│  LOGIQUE METIER (Python)                             │
│  → Regles R01-R08 : regex Python                     │
│  → Deduplication : difflib.SequenceMatcher           │
│  → Nettoyage : pandas vectorise                      │
│  → Regles custom : regex/conditions Python           │
├─────────────────────────────────────────────────────┤
│  DATA LAYER (SQL via Snowflake connector)             │
│  → Lecture tables : SELECT                           │
│  → Lookup INSEE : SELECT + Cortex Search Service     │
│  → Recherche semantique : SEARCH_PREVIEW()           │
│  → Persistance : INSERT INTO (batch)                 │
│  → IA : SNOWFLAKE.CORTEX.COMPLETE()                  │
├─────────────────────────────────────────────────────┤
│  STOCKAGE (Snowflake)                                │
│  → Tables metier : DQ_FINDINGS, DQ_CORRECTIONS...   │
│  → Registre INSEE : V_UNITE_LEGALE (Marketplace)    │
│  → Base vectorisee : SIRENE_COMPANY_SEARCH (13M)    │
│  → Cache : @st.cache_data (en memoire Python)        │
└─────────────────────────────────────────────────────┘
```

---
