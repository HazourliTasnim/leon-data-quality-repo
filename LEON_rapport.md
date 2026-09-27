# **Rapport Technique Léon Platform** 

Plateforme de qualité de données pour la conformité des entreprises françaises 

## **Table des matières** 

|**1**<br>**Résumé exécutif**|**3**|
|---|---|
|**2**<br>**Présentation du projet**|**3**|
|**3**<br>**Contexte et problématique**|**4**|
|3.1<br>Contexte réglementaire et métier . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>4|
|<br>3.2<br>Problématique technique . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>4|
|**4**<br>**Objectifs du projet**|**4**|
|4.1<br>Objectifs fonctionnels . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>4|
|<br>4.2<br>Objectifs techniques . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>5|
|**5**<br>**Fonctionnalités principales**|**5**|
|**6**<br>**Exigences fonctionnelles**|**6**|
|**7**<br>**Exigences non fonctionnelles**|**6**|
|**8**<br>**Technologies utilisées et justifcation**|**6**|
|**9**<br>**Architecture générale de l’application**|**6**|
|9.1<br>Vue d’ensemble . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>6|
|9.2<br>Principes architecturaux (tels que codés) . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>6|
|9.3<br>Séquence d’une analyse (wizard) . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>7|
|**10 Organisation du projet**|**10**|
|**11 Description détaillée des modules**|**10**|
|11.1 Authentifcation et session<br>. . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>10|
|<br>11.2 Couche d’accès aux données . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>11|
|11.3 Import de fchiers . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>11|
|11.4 Mapping de colonnes — hybride alias + IA<br>. . . . . . . . . . . . . . . .|. . . . . . . . .<br>11|
|<br>11.5 Moteur de règles (`run_snowflake_dq_analysis`) . . . . . . . . .|. . . . . . . . .<br>11|
|11.6 Croisement INSEE (SIRENE)<br>. . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>11|
|11.7 Pipeline de dédoublonnage déterministe — 3 phases . . . . . . . . . . . .|. . . . . . . . .<br>12|
|11.8 Agents Cortex ajoutés : auto-correction et vérifcation web<br>. . . . . . . .|. . . . . . . . .<br>12|
|11.9 Enrichissement SIRENE . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>13|
|11.10Scoring de confance par ligne . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>13|
|11.11SLA par règle et indicateur e-facturation . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>13|
|<br>11.12Résolution, tâches et écriture en retour . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>13|
|11.13Exports<br>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>13|
|11.14Import IA de règles métier . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>14|
|<br>11.15Chemin batch : la stored procedure . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>14|
|**12 Fonctionnement général de l’application**|**14**|
|12.1 Wizard « Lancer l’analyse » (5 étapes) . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>14|
|<br>12.2 Module France (historique, commenté) . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>15|
|12.3 Flow Data Cleaning (3 étapes) . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>15|
|<br>12.4 Trois notions de score . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . .<br>15|



Page 1 / 23 

|**13 Interfaces utilisateur (application Streamlit)**|**15**|
|---|---|
|13.1 Navigation et écrans . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>15|
|13.2 Contenu détaillé de la sidebar . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>15|
|13.3 Système de design . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>16|
|13.4 Choix ergonomiques notables . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>16|
|**14 Gestion des données**|**16**|
|14.1 Modèle de données observé . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>16|
|14.2 Référentiel SIRENE . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>16|
|14.3 Flux d’écriture<br>. . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>17|
|**15 Traitements principaux et logique métier**|**17**|
|15.1 Chaîne de traitement réelle . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>17|
|15.2 Détails métier remarquables (vérifés)<br>. . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>17|
|15.3 Ingénierie de prompt . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>18|
|**16 Gestion des erreurs et validation des données**|**18**|
|16.1 Ce qui est robuste . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>18|
|16.2 Le point faible : la politique_best-efort_ . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>18|
|**17 Sécurité et protection des données**|**18**|
|17.1 Points forts vérifés . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>18|
|17.2 Points de vigilance (corrigés et précisés) . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>18|
|**18 Performances et optimisations**|**19**|
|18.1 Optimisations vérifées dans le code . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>19|
|18.2 Points de contention (analyse du code) . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>19|
|**19 Difcultés rencontrées et solutions apportées**|**20**|
|**20 Procédure d’installation et de déploiement**|**20**|
|20.1 Prérequis<br>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>20|
|20.2 Installation et lancement<br>. . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . . . . . .<br>20|
|**21 Tests réalisés**|**21**|
|**22 Limites actuelles du projet**|**21**|
|**23 Améliorations possibles**|**22**|
|**24 Analyse critique : constats issus de la revue de code**|**22**|
|**25 Conclusion**|**23**|



Page 2 / 23 

## **1 Résumé exécutif** 

**Léon** (nom de code interne : _Qualitix_ ) est une plateforme B2B de _data quality_ dédiée à la mise en conformité des référentiels d’entreprises françaises : validation des identifiants légaux (SIREN, SIRET, TVA intracommunautaire, code NAF/APE), croisement avec le registre national INSEE, dédoublonnage et préparation à l’e-facturation (PDP). 

L’application est un **monolithe Streamlit** (Python 3.11, `app.py` , 5 416 lignes) connecté à **Snowflake** , qui concentre le stockage (schémas `COMMERCIAL_DATA` et `DATA_QUALITY` ), le référentiel SIRENE du Marketplace (29,6 M d’unités légales) et l’intelligence artificielle ( `SNOWFLAKE.CORTEX.COMPLETE()` avec le modèle `mistral-large2` ). Aucune donnée ne transite par une API externe. 

L’architecture d’exécution, telle qu’implémentée dans le code, est **hybride** : 

- le **dédoublonnage déterministe** en **trois phases** (SIREN/nom exact, puis normalisation de format, puis similarité par _blocking_ 5 caractères) et le _staging_ s’exécutent en SQL/pandas; 

- le **moteur de règles** R01–R08 + INSEE + règles personnalisées est porté par la fonction `run_snowflake_dq_analysis` , avec un paramètre `df_override` pour brancher un fichier importé sur le même moteur; 

- — une _stored procedure_ `SP_EXECUTE_BUSINESS_RULES` offre un chemin **batch alternatif** , déclenché manuellement; 

— **Cortex** est utilisé pour huit tâches sémantiques : mapping de colonnes, **import de règles métier depuis un fichier texte** , auto-correction multi-stratégie, jugement web, suggestion de règles, enrichissement SIRENE, clé de jointure et **recherche SIRENE par nom via Cortex Search Service** (embeddings `arctic-embed-l-v2.0`, ~13M sièges indexés) ; 

- deux **agents** : le _Web Verification Agent_ (scan Pappers / Google / Societe.com puis jugement LLM) et l’ _AI Auto-Correction Engine_ : déduction du SIREN depuis la TVA ou le SIRET, puis fuzzy INSEE, avec seuils de confiance 75 % / 85 %). 

Le tout est gouverné en _human-in-the-loop_ : les fusions de doublons sont confirmées groupe par groupe, l’écriture des données nettoyées exige une double confirmation, et chaque action est journalisée dans `DQ_AUDIT_LOG` . Toutes les écritures DML utilisent des **requêtes paramétrées** . 

|**Indicateur**|**Valeur (vérifée dans le code)**|
|---|---|
|Application|`app.py`—_∼_8 500 lignes, 7 écrans (login + 6 pages)|
|Référentiel croisé|SIRENE Marketplace :`V_UNITE_LEGALE`+`V_ETABLISSEMENT`|
|Règles standard|R01–R08 + croisement INSEE; dédoublonnage déterministe 3 phases|
|Règles personnalisées|4 types : regex, not_empty, in_list, length|
|Usages Cortex|8 : mapping, import de règles métier, auto-correction, jugement web, suggestion de règles,<br>enrichissement, clé de jointure, **recherche sémantique SIRENE (Cortex Search Service)**|
|Authentifcation|Password + MFA TOTP (optionnel)_ou_SSO`externalbrowser`|
|Interface|Thèmes dark/light,_∼_830 lignes de CSS injecté|



Table 1 – Chiffres clés du projet 

## **2 Présentation du projet** 

Léon s’adresse aux équipes data, CRM, finance et conformité qui gèrent des référentiels de comptes clients français et doivent garantir la validité formelle des identifiants légaux, leur existence réelle au registre INSEE, l’unicité des enregistrements et l’éligibilité à la facturation électronique (indicateur _einvoicing ready_ calculé par l’application). 

Le périmètre fonctionnel couvre le cycle complet : _import, mapping, nettoyage, analyse, scoring, résolution, export, audit_ . 

L’application expose sept écrans : la page de connexion Snowflake, puis six pages accessibles par la barre latérale, regroupées en trois blocs : **PRINCIPAL** (Tableau de bord, Données clients, Catalogue de 

Page 3 / 23 

règles, Lancer l’analyse), **RÉSULTATS** (Anomalies, Tâches) et **OUTILS** (Exports). Le module France est **désactivé** (commenté dans le code); ses fonctionnalités utiles — notamment le CRUD des règles personnalisées — sont intégrées au _Catalogue de règles_ . 

Les données vivent dans la base `QUALITY_TEST` . Le schéma `COMMERCIAL_DATA` contient les tables métier ( `DIM_ACCOUNT` , `DIM_ESTABLISHMENT` ), et le schéma `DATA_QUALITY` regroupe les artefacts de qualité : findings, corrections, règles personnalisées, résultats de dédoublonnage, scores, journal d’audit et table de staging ( `DQ_STAGING_IMPORT` ). 

## **3 Contexte et problématique** 

### **3.1 Contexte réglementaire et métier** 

- **E-facturation obligatoire (PDP)** : la réforme française impose l’identification fiable des entreprises par SIREN/SIRET; l’application calcule explicitement un indicateur _e-invoicing ready_ (SIREN valide + SIRET valide + cohérence). 

- **TVA intracommunautaire** : le code implémente la validation du format `FR` + clé + SIREN et sait même _calculer_ la clé TVA attendue à partir du SIREN (algorithme (12 +3 _×_ (SIREN mod 97)) mod 97). 

- **Référentiel vivant** : le registre SIRENE (Marketplace) est la source de vérité; le code le croise par jointures SQL et le met en cache par lots. 

### **3.2 Problématique technique** 

|**Problème classique**|**Réponse implémentée**|
|---|---|
|Les comparaisons strictes ratent les doublons « fous »|Double moteur : dédoublonnage déterministe par clés|
|(« Dupont SARL » vs « SARL Dupont »)|normalisées, puis détection de groupes par LLM (Cor-<br>tex) avec confance et justifcation|
|Le mapping des colonnes importées varie selon les<br>clients|Mapping**hybride**: dictionnaire d’alias<br>(`COLUMN_ALIASES`,_∼_60 variantes) en premier re-<br>cours, Cortex en mapping sémantique assisté|
|L’envoi de données à une API d’IA externe pose des<br>problèmes RGPD|`SNOWFLAKE.CORTEX.COMPLETE()`en SQL natif :<br>aucune donnée ne quitte Snowfake, pas de clé API|



Table 2 – Problématiques et réponses apportées 

## **4 Objectifs du projet** 

### **4.1 Objectifs fonctionnels** 

1. Valider automatiquement la conformité des identifiants légaux français sur toute table Snowflake ou fichier importé (CSV/Excel). 

2. Croiser les données avec le registre INSEE : existence du SIREN, mais aussi écarts de SIRET de siège, de raison sociale, d’adresse et de code NAF. 

3. Détecter et fusionner les doublons — par clés déterministes et par IA. 

4. Quantifier la qualité : score dataset, score de confiance par ligne, SLA par règle, indicateur e- facturation. 

5. Gouverner la correction : validation humaine, double confirmation des écritures, audit complet. 

6. Permettre l’extension par des règles métier personnalisées créées depuis l’interface, sans développement. 

Page 4 / 23 

### **4.2 Objectifs techniques** 

1. **Zéro sortie de données** : tout le traitement, IA comprise, reste dans le périmètre Snowflake. 

2. **Simplicité de déploiement** : une seule application Python, pas de backend dédié, connexion saisie au login (pas de fichier de secrets). 

3. **Réactivité** : cache Streamlit systématique (TTL 30 s à 600 s) et garde-fous de volumétrie ( `LIMIT` ). 

## **5 Fonctionnalités principales** 

|**#**|**Fonctionnalité**|**Implémentation vérifée**|
|---|---|---|
|F1|Import de données|Table Snowfake ou fchier CSV/Excel avec lecture robuste (4 encodages_×_4 sépara-<br>teurs, heuristique d’en-tête Excel)|
|F2|Mapping de colonnes|Hybride : alias (`COLUMN_ALIASES`) + Cortex (`detect_column_mapping_ai`,<br>réponse JSON validée contre les colonnes réelles)|
|F3|Moteur de règles|`run_snowflake_dq_analysis`: R01–R08, INSEE, règles custom; paramètre<br>`df_override`pour brancher un DataFrame importé|
|F4|Exécution batch SP|`SP_EXECUTE_BUSINESS_RULES`appelée manuellement (chemin batch alternatif)|
|F5|Règles personnalisées|CRUD complet sur`DQ_CUSTOM_RULES`(intégré au_Catalogue de règles_), 4 types<br>|
|F6|Dédoublonnage déterministe|Clés au choix (SIREN, SIRET, ID, nom, TVA), stratégies keep_frst/keep_last, SQL<br>fenêtré + repli pandas|
|F7|Pipeline dédup. 3 phases|Phase 1 : match exact SIREN/nom normalisé; phase 2 : normalisation de format; phase<br>3 : similarité avec_blocking_sur les 5 premiers caractères. Entièrement déterministe, sans<br>Cortex|
|F8|Croisement INSEE|Existence SIREN + écarts SIRET siège / raison sociale / adresse / NAF, cache par lots +<br>lookup unitaire|
|F9|Enrichissement SIRENE|Jointure à la demande sur 12 colonnes (dénomination, NAF, catégorie, efectifs,<br>adresse...), clé suggérée par Cortex|
|F10|Scoring de confance|Score par ligne = règles passées / applicables; score dataset = lignes sans anomalie|
|F11|SLA par règle|`compute_fr_sla()`: % de comptes conformes par règle, R08 dérivé de<br>R01+R02+R03|
|F12|Résolution & tâches|Cinq actions par anomalie :**Corriger AI**,**Vérifer web**, En revue, Résoudre, Rejeter;<br>traitement unitaire ou en masse; correction écrite en retour dans`DIM_ACCOUNT`|
|F13|Exports|3 CSV téléchargeables (comptes, anomalies, corrections) : chaque colonne origi-<br>nale est suivie d’une colonne`[CORRIGÉ] field`intercalée, alimentée depuis<br>`DQ_CORRECTIONS`; sauts de ligne nettoyés; CSV UPDATE « prêt CRM » et rap-<br>port e-facturation|
|F14|Audit trail|`DQ_AUDIT_LOG`alimenté sur chaque action signifcative|
|F15|Wizard d’analyse|5 étapes, multi-tables, barre de progression, durée mesurée|
|F16|Authentifcation|Formulaire Snowfake avec choix**Password + TOTP (optionnel)**_ou_**SSO**<br>(`authenticator="externalbrowser"`), test`SELECT 1`|
|F17|Thèmes|Dark/light avec tokens de couleurs, CSS injecté|
|F18|**Web Verifcation Agent**|Scan Pappers, Google et Societe.com pour un compte donné puis**jugement**<br>**LLM**sur la cohérence des indices trouvés; verdict attaché à la fnding via<br>`_web_verify_finding`|
|F19|**AI Auto-Correction Engine**|`_auto_correct_finding`: stratégies enchaînées (déduction du SIREN depuis<br>la TVA, depuis le SIRET, fuzzy INSEE par nom) avec des seuils de confance**75 % /**<br>**85 %**; correction proposée à l’utilisateur avant écriture|
|F20|**Import IA de règles métier**|Upload d’un fchier texte (`.txt`,`.csv`,`.md`,`.pdf`,`.docx`) à l’étape 2 du wizard;<br>parsing par Cortex, aperçu master-detail avec toggles pour activer/rejeter chaque règle,<br>import en masse dans`DQ_CUSTOM_RULES`|



Table 3 – Fonctionnalités principales 

Page 5 / 23 

## **6 Exigences fonctionnelles** 

Les sévérités et comportements ci-dessous sont ceux effectivement codés — ils diffèrent par endroits de la documentation initiale (sévérités graduées, règle DUP, TVA calculée). 

|**ID**|**Exigence (comportement codé)**|**Sévérité**|
|---|---|---|
|EF-01|SIREN : exactement 9 chifres (`regex \d{9}`); SIREN et SIRET tous deux absents_⇒_anoma-<br>lie|HIGH|
|EF-02|SIRET : exactement 14 chifres|HIGH|
|EF-03|Cohérence : les 9 premiers chifres du SIRET = SIREN — testée seulement si les deux formats<br>sont valides|HIGH|
|EF-04|TVA : format`FR`+ clé + SIREN; si TVA vide avec SIREN valide sur compte FR, anomalie avec<br>_valeur attendue calculée_|HIGH|
|EF-05|Filtre France : pays_∈_{FR, FRA, FRANCE, vide}_ou_ville française (heuristique CEDEX / code<br>postal / sufxe FR)|fltre|
|EF-06|NAF : 4 chifres + 1 lettre (points ignorés); format invalide = MEDIUM, champ absent = LOW|MEDIUM/LOW|
|EF-07|Forme juridique : vide et non extractible du nom (regex SA, SAS, SARL, EURL...)|MEDIUM|
|EF-08|E-facturation (dérivée) : SIREN valide + SIRET valide + cohérence|indicateur|
|EF-09|DUP : SIREN déjà vu dans le fchier (désactivée si dédoublonnage préalable)|HIGH|
|EF-10|INSEE : SIREN absent du registre = MEDIUM; SIRET=siège = HIGH; écarts nom/adresse =<br>MEDIUM; écart NAF = LOW|graduée|
|EF-11|Règles personnalisées : regex, not_empty, in_list, length (`min:max`)|confgurable|
|EF-12|Fusion de doublons confrmée groupe par groupe; possibilité d’ignorer|—|
|EF-13|Score ligne = passées / applicables_×_100; ligne sans règle applicable = 100|—|
|EF-14|Cycle de vie : Open, In Review, Resolved, Dismissed|—|
|EF-15|Double confrmation avant écriture des données nettoyées (écrasement de table) et avant rejet<br>groupé|—|
|EF-16|Journalisation de chaque action (règle créée, cleaning, écriture, correction, SP)|—|



Table 4 – Exigences fonctionnelles vérifiées dans le code 

## **7 Exigences non fonctionnelles** 

Aucune exigence chiffrée de temps de réponse ni de SLA de disponibilité n’est exprimée dans le code; les `LIMIT` tiennent lieu de garde-fous de volumétrie (avec l’effet de bord analysé en §24). 

## **8 Technologies utilisées et justification** 

#### **Point clé** 

Arbitrage structurant confirmé par le code : le choix «tout Snowflake» (données, référentiel, IA) troque une dépendance fournisseur contre une posture de sécurité et une simplicité opérationnelle fortes. En revanche, le moteur de règles a été implémenté en Python plutôt qu’en SQL — un second arbitrage qui privilégie la richesse des contrôles (heuristiques de ville, extraction de forme juridique, TVA calculée) au détriment de la scalabilité (cf. §18). 

## **9 Architecture générale de l’application** 

### **9.1 Vue d’ensemble** 

### **9.2 Principes architecturaux (tels que codés)** 

1. **Exécution hybride** : le SQL Snowflake prend en charge ce qui est massif et ensembliste (staging `write_pandas` , dédoublonnage fenêtré, jointures SIRENE, cache SIRENE par lots); Py- 

Page 6 / 23 

|**Catégorie**|**Exigence**|**Mise en œuvre codée**|
|---|---|---|
|Confdentialité|Aucune donnée ne quitte Snowfake|Cortex en SQL natif; exports = téléchargements<br>CSV à l’initiative de l’utilisateur|
|Sécurité|Écritures sûres|DML systématiquement paramétré (`%(x)s`);<br>échappement des apostrophes dans les prompts<br>Cortex|
|Authentifcation|Connexion Snowfake|Password + TOTP_optionnel_; test`SE-`<br>`LECT 1`; connexion mise en cache<br>(`st.cache_resource`)|
|Traçabilité|Auditabilité|`DQ_AUDIT_LOG`+ horodatage; utilisateur repris<br>de la session|
|Gouvernance|Human-in-the-loop|Confrmation par groupe de doublons; double<br>confrmation d’écriture; « Ignorer » toujours<br>possible|
|Réactivité|Limiter les requêtes|`st.cache_data`avec TTL<br>30/60/120/300/600 s selon la volatilité;`LIMIT`<br>5000/2000/100|
|Robustesse d’import|Fichiers hétérogènes|4 encodages_×_4 séparateurs testés, heuristique<br>d’en-tête Excel, messages d’erreur explicites|
|Lisibilité|Restitution visuelle|Score coloré (vert_≥_80 %, orange 50–79 %, rouge<br>_<_50 %), badges de sévérité, thèmes dark/light|



Table 5 – Exigences non fonctionnelles 

thon prend en charge ce qui est riche et conditionnel (règles R01–R08 avec heuristiques, scoring d’applicabilité). La _stored procedure_ n’est qu’un chemin batch secondaire. 

2. **IA colocalisée et bordée** : chaque appel Cortex impose un format de sortie, extrait le JSON de façon tolérante (blocs `“‘` , `re.search` ), valide le résultat contre les données réelles (colonnes existantes, indices valides) et prévoit un repli déterministe en cas d’échec. 

3. **Couche d’accès unique** : toutes les lectures passent par `_sf_query` , toutes les écritures par `_sf_execute` (paramétré) — avec une politique _best-effort_ assumée (exceptions avalées, cf. §16). 

4. **Human-in-the-loop** : détection, puis preview, puis confirmation ou « Ignorer »; écriture finale derrière une double confirmation explicite (« cette action écrase la table »). 

### **9.3 Séquence d’une analyse (wizard)** 

Page 7 / 23 

|**Technologie**|**Rôle**|**Justifcation et usage réel**|
|---|---|---|
|Streamlit|Frontend, orchestration|UI data en Python pur; le code ex-<br>ploite`session_state`(wi-<br>zard, sous-états du cleaning),<br>`st.cache_data`/`cache_resource`,<br>formulaires, onglets, expanders et une in-<br>jection CSS massive pour un rendu « pro-<br>duit ».|
|Python 3.11|Langage applicatif|Type hints modernes (`str | None`);<br>pandas pour le moteur de règles et le dé-<br>doublonnage local.|
|Snowfake|Stockage, staging, référentiel|Tables transientes de staging, dédoublon-<br>nage`ROW_NUMBER()`fenêtré, jointures<br>SIRENE;`write_pandas`pour le char-<br>gement en masse.|
|Cortex (`mistral-large2`)|7 tâches sémantiques|Fonction SQL native, pas de clé API;<br>prompts avec format de sortie imposé<br>(JSON), extraction tolérante (blocs`“‘`,<br>regex), validation des sorties contre les<br>données réelles.|
|`snowflake-connector-python`|Connexion, requêtage|Paramètre`passcode`pour le TOTP;<br>`login_timeout=120`; requêtes<br>paramétrées pour le DML;`pan-`<br>`das_tools.write_pandas`.|
|pandas|Moteur de règles, dédoublonnage local|`iterrows()`ligne à ligne,`duplica-`<br>`ted()`par clé normalisée,`merge`pour<br>l’enrichissement SIRENE.|
|plotly|Visualisations|`plotly.express`et<br>`graph_objects`avec habillage thème<br>(`plotly_layout`).|



Table 6 – Technologies et usages réels 

**STREAMLIT — app.py (** _∼_ **8 500 lignes)** 



<!-- Start of picture text -->
6 pages Moteur de règles<br>Login Sidebar<br>Dashboard, Données clients, Règles, run_snowflake_dq_analysis<br>Password/TOTP  ou  SSO PRINCIPAL / RÉSULTATS / OUTILS<br>Wizard, Anomalies, Tâches, Exports R01–R08 · INSEE · custom<br>snowflake.connector<br>DATA_QUALITY<br>COMMERCIAL_DATA<br>DQ_FINDINGS DQ_CORRECTIONS CORTEX AI<br>DIM_ACCOUNT DQ_CUSTOM_RULES DQ_AUDIT_LOG<br>mistral-large2<br>DIM_ESTABLISHMENT DQ_DEDUP_RESULTS DQ_SCORING<br>DQ_STAGING_IMPORT (+ _CLEAN) 7 usages<br>SP_EXECUTE_BUSINESS_RULES MARKETPLACE SIRENE<br>chemin batch (onglet dédié) V_UNITE_LEGALE (29,6 M)  ·  V_ETABLISSEMENT<br>SNOWFLAKE — QUALITY_TEST<br><!-- End of picture text -->

Figure 1 – Architecture générale — moteur de règles côté application, pipeline dédup. 3 phases déterministe, agents web-verify et auto-correction côté Cortex 

Page 8 / 23 



<!-- Start of picture text -->
Utilisateur Streamlit Snowflake Cortex SIRENE<br>login (TOTP  ou  SSO externalbrowser)<br>connect · SELECT 1<br>wizard : sujets + périmètre<br>Phase 1 — match exact  SIREN / nom normalisé (pandas)<br>Phase 2 — normalisation de format  (SIREN sur 9 chiffres, casse, ponctuation)<br>Phase 3 — similarité  avec  blocking  sur 5 premiers caractères<br>dédoublonnage déterministe — pas d’appel Cortex<br>staging ( write_pandas  /  executemany  %s)<br>règles R01–R08 + custom via  run_snowflake_dq_analysis<br>croisement INSEE : cache par lots + lookups<br>INSERT DEDUP_RESULTS + AUDIT (paramétré)<br>résolution : 5 actions (Corriger AI · Vérifier web · ...)<br>COMPLETE(auto-correct  ou  judge-web)<br><!-- End of picture text -->

Figure 2 – Séquence réelle d’une analyse (v3) — dédoublonnage déterministe en 3 phases, agents Cortex à la résolution 

Page 9 / 23 

## **10 Organisation du projet** 

Le code applicatif tient dans un seul fichier, structuré en sections par des séparateurs de commentaires. 

|**Section d’****`app.py`**|**Lignes (**_≈_**)**|**Contenu**|
|---|---|---|
|Theme tokens & constantes|15–230|Thèmes dark/light, pages, traductions,`RULE_TEMPLATES`,`ANALY-`<br>`SIS_SUBJECTS`, règles R01–R08, alias de colonnes, référence SIRENE|
|Couche d’accès Snowfake|230–445|Connexion (cache),`_sf_query`/`_sf_execute`, chargements avec TTL,<br>écritures paramétrées, appel SP|
|CRUD règles personnalisées|445–490|`list/create/toggle/delete_custom_rule`|
|Scoring persisté|490–530|`persist_scoring`/`load_scoring`(_non appelés_— cf. §24)|
|Dédoublonnage & staging|530–785|Dédoublonnage pandas et SQL,`write_pandas`,<br>`run_snowflake_dq_analysis`|
|CSS / composants UI|1 077–2 010|_∼_830 lignes de CSS injecté, badges, cartes, KPI, en-têtes|
|Import & moteur de règles|2 167–2 680|Lecture fchiers, mapping (alias + IA), validateurs, croisement INSEE,`ana-`<br>`lyze_uploaded_dataframe`|
|Sidebar & pages|(bloc central)|6 pages actives + wizard + enrichissement SIRENE + exports; module France<br>commenté (désactivé)|
|Agents Cortex|(blocs dédiés)|`_auto_correct_finding`(multi-stratégie avec seuils 75/85 %),<br>`_web_verify_finding`(Pappers/Google/Societe.com + jugement LLM),<br>pipeline dédup. 3 phases|
|Login & main|(fn de fchier)|Formulaire de connexion avec**radio Password/SSO**, routage<br>`PAGE_RENDERERS`|



_∼_ Table 7 – Organisation interne d’ `app.py` ( 8 500 lignes) 

Points notables vérifiés : **aucun fichier** **`secrets.toml` n’est lu** — les identifiants Snowflake sont saisis dans le formulaire de login, et le SSO `externalbrowser` est proposé en alternative dans le même formulaire (radio Password/SSO). Le nom de code interne reste _Qualitix_ (docstring, préfixes CSS `qx-` historiques), distinct du nom de produit Léon retenu pour ce rapport. Le logo affiché est désormais une illustration SVG (personnage avec bonnet, lunettes et étoile), et non plus le sigle « Q » des premières versions. 

#### **Hypothèse** 

`setup_snowflake.sql` (DDL des tables et corps de la _stored procedure_ ) a été supprimé du dépôt : la structure des tables est reconstituée à partir des `INSERT` / `SELECT` du code, et le contenu exact de `SP_EXECUTE_BUSINESS_RULES` reste non vérifiable dans les sources actuelles. 

## **11 Description détaillée des modules** 

### **11.1 Authentification et session** 

- Formulaire Streamlit avec **choix explicite** du mode d’authentification via une radio _Password_ / _SSO_ : 

- mode _Password_ : compte, utilisateur, mot de passe, code TOTP _optionnel_ , warehouse; 

- mode _SSO_ : compte, utilisateur, warehouse, avec `authenticator="externalbrowser"` déclenchant une redirection navigateur vers l’IdP configuré. 

La connexion est construite par `_build_conn` (décorée `@st.cache_resource` ) et validée par un `SELECT 1` . 

Listing 1 – Connexion réelle (extrait) 

```
@st . cache_resource
def_build_conn ( account ,user ,password ,warehouse ,
passcode ="",authenticator =""):
params=dict ( account = account ,user =user ,warehouse = warehouse ,
login_timeout =120)
```

Page 10 / 23 

```
ifauthenticator==" externalbrowser ":#modeSSO
params [" authenticator "]=" externalbrowser "
params [" user "]=user
else :#modepassword
params [" password "]=password
ifpasscode :#MFATOTPoptionnel
params [" passcode "]=passcode
returnsf_connector . connect (** params )
```

### **11.2 Couche d’accès aux données** 

Deux primitives centralisent tous les échanges : `_sf_query(sql)` (lecture, colonnes normalisées en minuscules, DataFrame vide en cas d’erreur) et `_sf_execute(sql, params)` (écriture **toujours paramétrée** , politique _best-effort_ : les exceptions sont silencieusement absorbées). Les chargements sont mis en cache avec des TTL gradués selon la volatilité : audit 30 s, findings/règles/scoring 60 s, recherche INSEE par nom 120 s, comptes/cache SIRENE/mapping IA 300 s, listes de bases 600 s. 

### **11.3 Import de fichiers** 

`load_uploaded_file` lit les Excel avec une heuristique de ligne d’en-tête, puis tente pour les CSV le produit cartésien de 4 encodages (utf-8, utf-8-sig, latin-1, cp1252) et 4 séparateurs ( `; ,` tabulation `|` ), en ignorant les lignes malformées ( `on_bad_lines="skip"` ); l’échec lève un `ValueError` avec un message d’aide en français. 

### **11.4 Mapping de colonnes — hybride alias + IA** 

Deux mécanismes complémentaires : 

- `detect_column_mapping` : dictionnaire `COLUMN_ALIASES` ( _∼_ 60 variantes françaises et anglaises, p. ex. `raison_sociale` , `libellé` , `tva_intracom` ) après normalisation des en-têtes; 

- `detect_column_mapping_ai` : prompt Cortex décrivant les 10 champs cibles, exigeant un JSON pur; la réponse est nettoyée (blocs `“‘json` ), parsée, puis **validée champ par champ** contre les colonnes réelles (correspondance insensible à la casse, `null` sinon); en cas d’exception, repli sur un mapping vide. Résultat mis en cache 300 s. 

L’utilisateur peut ensuite corriger le mapping proposé dans l’interface. 

### **11.5 Moteur de règles (** **`run_snowflake_dq_analysis` )** 

Le cœur du produit. La fonction `run_snowflake_dq_analysis` orchestre l’exécution : elle peut lire une table Snowflake (mode standard) ou consommer un DataFrame passé via le paramètre `df_override` (fichiers importés), déclenche le dédoublonnage (voir §11.7), puis applique les contrôles ligne par ligne (normalisation SIREN/SIRET, majuscules TVA/pays, détection du pays via la ville si absent). 

### **11.6 Croisement INSEE (SIRENE)** 

Bien plus riche qu’un simple test d’existence. Pour chaque SIREN valide d’un compte français : consultation du **cache par lots** ( `load_sirene_cache` pré-charge en une requête `IN (...)` tous les SIREN de `DIM_ACCOUNT` ) puis _lookup_ unitaire en repli. Anomalies produites : SIREN absent du registre (MEDIUM), SIRET différent du siège (HIGH, avec le SIRET attendu), écart de raison sociale (MEDIUM, comparaison par inclusion croisée), écart d’adresse (MEDIUM, préfixes de 20 caractères), écart de code NAF (LOW). La recherche par nom utilise désormais le **Cortex Search Service** `SIRENE_COMPANY_SEARCH` (~13M sièges indexés avec `snowflake-arctic-embed-l-v2.0`) via la fonction `_cortex_search_sirene` : la requête passe par `SNOWFLAKE.CORTEX.SEARCH_PREVIEW()` et retourne les meilleures correspondances sémantiques (seuil cosine ≥ 0.35). Un fallback vers EDITDISTANCE+SOUNDEX reste disponible si le service est indisponible. 

Page 11 / 23 

|**ID**|**Comportement codé**|**Sévérité**|
|---|---|---|
|R01|`\d{9}`; SIREN et SIRET tous deux vides_⇒_« SIREN manquant »|HIGH|
|DUP|Doublon intra-fchier détecté — couvert en amont par le pipeline dédup. 3 phases (§11.7), non<br>ré-émis après nettoyage|HIGH|
|R02|`\d{14}`|HIGH|
|R03|`siret.startswith(siren)`— évaluée seulement si R01 et R02 passent|HIGH|
|R04|Format`FR[A-HJ-NP-Z0-9]{2}\d{9}`ou`FR\d{11}`; TVA vide + SIREN valide +<br>compte FR_⇒_anomalie avec TVA_calculée_en valeur attendue|HIGH|
|R05|Filtre : pays_∈_{vide, FR, FRA, FRANCE} ou ville française (heuristique CEDEX / code postal<br>5 chifres / sufxe FR)|fltre|
|R06|4 chifres + lettre (points tolérés); invalide = MEDIUM, absent = LOW|MEDIUM/LOW|
|R07|Vide_et_non extractible du nom par la regex des formes juridiques (SA, SAS, SARL, SASU,<br>EURL, SCI, GIE...)|MEDIUM|
|R08|Indicateur_e-invoicing ready_agrégé (R01_∧_R02_∧_R03), pas une anomalie par ligne|dérivée|
|Custom|regex / not_empty / in_list / length, chargées automatiquement depuis`DQ_CUSTOM_RULES`si<br>actives|confgurable|



Table 8 – Règles telles qu’implémentées 

### **11.7 Pipeline de dédoublonnage déterministe — 3 phases** 

Le dédoublonnage repose sur un **pipeline déterministe à trois phases** , exécuté en amont de l’analyse. Cette architecture garantit une reproductibilité totale, un coût nul et une scalabilité contrôlée. 

|**Phase**|**Rôle**|**Implémentation codée**|
|---|---|---|
|**1 — Match exact**|Fusion des lignes identiques par identifant<br>ou nom canonique|Comparaison SIREN normalisé (chifres<br>seuls) ou raison sociale normalisée (upper<br>+ strip + ponctuation retirée); complexité<br>_O_(_n_)via`groupby`pandas /`ROW_NUMBER`<br>SQL|
|**2 — Normalisation de format**|Rapprochement des variantes triviales<br>(espaces, casse, ponctuation, SIREN à 9<br>chifres)|Deuxième passe sur les clés normalisées<br>agressivement :`REGEXP_REPLACE`, upper,<br>retrait des sigles juridiques|
|**3 — Similarité (****_blocking_)**|Doublons « fous » (inversions, abréviations)<br>sans coût quadratique|_Blocking_sur les**5 premiers caractères**de<br>la raison sociale normalisée; comparaison<br>par similarité seulement à l’intérieur de<br>chaque bloc, complexité_O_<br>�<br>∑_b |b|_<sup>2�</sup><br>au lieu<br>de_O_(_n_<sup>2</sup>)|



Table 9 – Pipeline de dédoublonnage déterministe en 3 phases 

Les clés configurables (SIREN, SIRET, ID compte, raison sociale, TVA) et les stratégies _keep_first_ / _keep_last_ sont conservées; deux moteurs coexistent toujours (SQL Snowflake avec `ROW_NUMBER() OVER (PARTITION BY ...)` pour les phases 1–2 sur les tables, pandas pour les fichiers uploadés et la phase 3). Chaque exécution alimente `DQ_DEDUP_RESULTS` avec la stratégie ( `keep_first` / `3phase` ) et les clés utilisées. 

### **11.8 Agents Cortex ajoutés : auto-correction et vérification web** 

Deux **agents** Cortex opèrent au moment de la _résolution_ d’une anomalie. Ils complètent le pipeline déterministe (§11.7) par des actions ciblées appuyant la décision de l’utilisateur. 

**AI Auto-Correction Engine (** **`_auto_correct_finding` ).** Multi-stratégie : selon la nature de l’anomalie, l’agent tente en cascade **déduction TVA vers SIREN** (à partir de la clé de la TVA intracom), **extraction SIRET vers SIREN** (9 premiers chiffres), puis **fuzzy INSEE par nom** (recherche similitude sur `V_UNITE_LEGALE` + jugement Cortex sur les candidats). Chaque stratégie renvoie une _valeur proposée_ avec un score de confiance; deux **seuils** pilotent la décision : **75 %** pour proposer la correction à 

Page 12 / 23 

l’utilisateur, et **85 %** pour la marquer applicable en un clic. Sous 75 %, l’agent ne propose rien plutôt que d’introduire une erreur. 

**Web Verification Agent (** **`_web_verify_finding` ).** Pour une anomalie donnée, l’agent lance un scan de sources publiques ( _Pappers_ , _Google_ , _Societe.com_ ) autour du nom et éventuellement du SIREN, agrège les indices trouvés, puis appelle Cortex en _judge_ : le LLM produit un verdict structuré (cohérent / divergent, éléments concordants, éléments contradictoires). Le verdict est attaché à la finding pour appuyer la décision humaine. Cette approche — récupération déterministe puis jugement LLM — limite le rôle du LLM à ce qu’il fait bien (raisonnement sur du texte), sans lui déléguer l’accès aux données. 

### **11.9 Enrichissement SIRENE** 

`enrich_with_sirene` joint le DataFrame de l’utilisateur au Marketplace sur SIREN ou SIRET (jusqu’à 5 000 valeurs par `IN` ) et rapporte au choix 12 colonnes officielles (dénomination, NAF et son libellé, catégorie juridique, état administratif, catégorie d’entreprise, tranche d’effectifs, adresse complète, code postal, commune, département, région). La clé de jointure est suggérée par Cortex via `_suggest_join_key_ai` , avec repli heuristique sur les noms de colonnes. 

### **11.10 Scoring de confiance par ligne** 

Implémenté dans l’onglet Data Cleaning : pour chaque ligne, ratio _règles passées / règles applicables_ avec la logique d’applicabilité suivante (vérifiée dans le code) : 

|**Contrôle**|**Applicabilité codée**|
|---|---|
|R01 / R02|Applicables dès que la colonne est mappée; valeur manquante = échec|
|R03|Applicable uniquement si SIREN_et_SIRET sont tous deux valides (pas de double pénalité)|
|R04 / R06|Applicables uniquement si la valeur est renseignée (champ vide = non pénalisé)|
|R07|Valeur présente = réussi; absente mais extractible du nom =_non applicable_; sinon échec|
|Custom|Chaque règle active dont le champ est mappé compte dans l’applicable|



Table 10 – Logique d’applicabilité du score par ligne 

Une ligne sans aucune règle applicable reçoit 100. L’interface agrège : score moyen, lignes fiables ( _≥_ 80 %), lignes critiques ( _<_ 50 %), avec coloration conditionnelle de la colonne Score. **Ce score n’est pas persisté** : la fonction `persist_scoring` existe mais n’est jamais appelée (cf. §24). 

### **11.11 SLA par règle et indicateur e-facturation** 

`compute_fr_sla` calcule, par règle R01–R08, le pourcentage de comptes conformes (comptes distincts en échec soustraits du total). R08 est dérivé : comptes sans aucun échec R01/R02/R03 = prêts pour l’e-facturation. _Cette fonction est héritée du module France désactivé_ ; l’indicateur `einvoicing_ready` reste calculé et exposé, la vue SLA détaillée n’est en revanche plus câblée à une page active. 

### **11.12 Résolution, tâches et écriture en retour** 

Le centre de résolution (onglet France) et la page Tâches partagent un composant de **traitement en masse** ( `_render_bulk_action_table` ) : tout sélectionner, accepter ( _n_ ), rejeter ( _n_ ) avec motif et confirmation du rejet groupé. `fr_resolve_anomaly` écrit la correction dans `DQ_CORRECTIONS` , met à jour le statut dans `DQ_FINDINGS` et, si une valeur corrigée est acceptée, **met à jour la table source** `DIM_ACCOUNT` (UPDATE paramétré du champ concerné), puis journalise. 

### **11.13 Exports** 

La page _Exports_ propose trois CSV téléchargeables datés (comptes, anomalies, corrections). Les exports ont été refondus autour de deux principes : 

Page 13 / 23 

- **Colonnes de correction intercalées** : dans le CSV des comptes, chaque colonne originale est immédiatement suivie d’une colonne `[CORRIGÉ] <field>` qui expose la valeur corrigée proposée ou acceptée. La lecture reste alignée sur la table d’origine et le rapprochement est immédiat pour l’utilisateur métier. 

- **Chargement des corrections depuis la base** : les valeurs corrigées sont lues à la volée dans `DQ_CORRECTIONS` plutôt que reconstruites côté client, ce qui garantit la cohérence avec l’état après résolution. 

Les valeurs textuelles subissent en outre un **nettoyage des sauts de ligne** pour ne pas casser le format CSV. En parallèle, l’onglet Audit & Export historique du module France exposait un CSV « UPDATE corrections » prêt pour le CRM ( `ACCOUNT_ID` , `FIELD` , `OLD_VALUE` , `NEW_VALUE` , `RULE_ID` , `READY_FOR_CRM` ) et un rapport e-facturation avec les SLA par règle. 

### **11.14 Import IA de règles métier** 

À l’ **étape 2 du wizard** d’analyse, l’utilisateur peut téléverser un fichier texte décrivant des règles métier dans un format libre : `.txt` , `.csv` , `.md` , `.pdf` ou `.docx` . Le contenu est extrait puis soumis à Cortex avec un prompt qui exige une sortie JSON structurée (une entrée par règle, comportant `name` , `description` , `target_field` , `rule_type` , `pattern` , `severity` ). La réponse est validée : chaque `target_field` est rapproché des champs standard mappés, chaque `rule_type` est contraint aux quatre types supportés ( `regex` , `not_empty` , `in_list` , `length` ), et les règles non conformes sont écartées. 

L’interface présente le résultat sous forme **master-detail** : la liste des règles proposées à gauche, le détail à droite. Chaque règle porte un **toggle actif/inactif** et un bouton _Rejeter_ ; les règles retenues sont insérées en masse dans `DQ_CUSTOM_RULES` (une transaction, identifiants `Cnnn` générés séquentiellement) et deviennent immédiatement disponibles pour le moteur de règles. Chaque import est journalisé dans `DQ_AUDIT_LOG` avec le nom du fichier, le nombre de règles proposées et le nombre effectivement importées. 

Cet usage constitue le **huitième appel Cortex** de l’application — un cas d’IA générative à sortie structurée, doublé d’une validation stricte et d’une confirmation humaine par règle avant écriture. 

### **11.15 Chemin batch : la stored procedure** 

`SP_EXECUTE_BUSINESS_RULES(table)` est appelée par `CALL` depuis l’onglet « Exécution batch Snowflake » uniquement; le résultat textuel est affiché et l’action auditée. C’est un **chemin d’exécution secondaire** , parallèle au moteur Python. 

## **12 Fonctionnement général de l’application** 

### **12.1 Wizard « Lancer l’analyse » (5 étapes)** 



<!-- Start of picture text -->
1. Sujets<br>2. Périmètre<br>Conformité<br>Table + table 3. Data Cleaning 4. Exécution<br>(P1), Doublons 5. Résultats<br>(P2),(P1),WebAdresse(P3) additionnelle,dédoublonnagerègles, Cortexl’utilisateurdétecte, SQL,Dédoublonnagestaging, règles Score,des anomaliesKPI, aperçu<br>Tout sélectionner + import IA confirme ou ignore Python, INSEE<br>/ Tout rejeter de règles<br><!-- End of picture text -->

Figure 3 – Wizard d’analyse tel qu’implémenté ( `page_run_analysis` ) 

Détails vérifiés : l’ **étape 1** propose deux boutons de saisie rapide _Tout sélectionner_ / _Tout rejeter_ sur les sujets, en plus des cases individuelles; l’ **étape 2** permet d’ajouter une **table additionnelle** ( `DIM_ESTABLISHMENT` ) analysée avec les mêmes règles, et d’ **importer des règles métier depuis un fichier texte** via Cortex (§11.14); l’étape 3 offre systématiquement « Passer (pas de cleaning) » et « Ignorer 

Page 14 / 23 

les doublons »; l’étape 4 exécute `run_snowflake_dq_analysis` par table, agrège les statistiques (HIGH/MEDIUM/LOW) et mesure la durée réelle; l’étape 5 affiche le score en grand format coloré, quatre KPI, l’aperçu des 20 premières anomalies et le comparatif avant/après nettoyage. 

### **12.2 Module France (historique, commenté)** 

Une version antérieure du code exposait un _Module France_ regroupant six onglets ( _Source & Analyse_ , _Règles métier_ , _Data Cleaning_ , _Tableau de bord_ , _Centre de résolution_ , _Audit & Export_ ). Ce module est aujourd’hui commenté dans le code : la sidebar ne l’expose plus, et ses fonctionnalités utiles ont été redistribuées dans les pages actives (CRUD des règles dans le _Catalogue de règles_ , résolution centralisée dans _Anomalies_ , dédoublonnage confié au pipeline déterministe 3 phases). Le code est conservé comme historique et peut être réactivé. 

### **12.3 Flow Data Cleaning (3 étapes)** 

1. **Détection** — Cortex propose des groupes (confiance, raison), affichés avec les lignes concernées. 

2. **Confirmation** — fusion Cortex groupe par groupe, ou « Ignorer les doublons ». 

3. **Analyse** — règles R01–R08 + INSEE + custom sur les données nettoyées, règle DUP désactivée ( `skip_duplicate_check` ), scoring par ligne, puis actions : « Écrire sur Snowflake » (double confirmation, écrasement de la table), « Recommencer », « Voir dans Résolution ». 

### **12.4 Trois notions de score** 

Le code distingue trois métriques qu’il ne faut pas confondre : 

|**Score**|**Défnition codée**|**Où**|
|---|---|---|
|Score dataset|lignes sans anomalie / total_×_100|Wizard (étape 5), analyses|
|Score par ligne|règles passées / règles applicables_×_100|Onglet Data Cleaning|
|Quick score|% de lignes sans problème de format SIREN/SIRET (avant nettoyage)|Comparatif avant/après|



Table 11 – Les trois métriques de qualité 

## **13 Interfaces utilisateur (application Streamlit)** 

### **13.1 Navigation et écrans** 

### **13.2 Contenu détaillé de la sidebar** 

Au-delà des trois blocs de navigation, la sidebar embarque plusieurs éléments contextuels qui contribuent à la lisibilité opérationnelle : 

- un **indicateur « Source connectée** _·_ **Snowflake »** en haut, qui confirme visuellement l’état de la session ( `@st.cache_resource` ) — un simple coup d’œil suffit pour savoir si l’application est reliée à un compte Snowflake; 

- un **expander « Configuration »** donnant à l’utilisateur la maîtrise du périmètre analysé sans quitter l’écran courant : sélecteurs _Database_ et _Schema_ (listes chargées avec TTL de 600 s), sélecteur _Table_ par défaut ( `DIM_ACCOUNT` ), et un widget d’ **upload** qui rejoint directement le pipeline d’import de fichiers; 

- un bouton **« Sign out »** qui vide `st.session_state` , purge les caches ( `cache_resource .clear()` et `cache_data.clear()` ) et redirige vers le formulaire de connexion. 

Ce regroupement en pied de sidebar respecte le patron classique Streamlit — les éléments de session en marge, la navigation au centre. 

Page 15 / 23 

|**Écran**|**Contenu vérifé**|**Interactions clés**|
|---|---|---|
|_Login_|||
|Login|Compte, utilisateur, mot de passe + TOTP_ou_SSO<br>externalbrowser, warehouse|Validation`SELECT 1`, erreurs afchées|
|_PRINCIPAL_|||
|Tableau de bord|KPI, tendance de conformité (30 j), anomalies par<br>règle, dimensions|Graphiques plotly thémés|
|Données clients|Table`DIM_ACCOUNT`|Consultation|
|Catalogue de règles|Règles standard R01–R08 + CRUD des règles<br>personnalisées (ex-module France) + templates|Créer, activer, désactiver, supprimer|
|Lancer l’analyse|Wizard 5 étapes avec fl d’Ariane visuel|Cases sujets, sélecteurs, boutons Retour/Suivant|
|_RÉSULTATS_|||
|Anomalies|Boîte de réception paginée|Filtres sévérité/statut; par anomalie : Corriger AI,<br>Vérifer web, En revue, Résoudre, Rejeter|
|Tâches|Workfow de data stewardship|Bulk accept (passe En revue) / reject (passe Re-<br>jeté)|
|_OUTILS_|||
|Exports|3 rapports CSV datés|Boutons de téléchargement|



Table 12 – Écrans de l’application (7 écrans, sidebar en 3 blocs; module France retiré) 

### **13.3 Système de design** 

Le code embarque un véritable système de design : deux thèmes (dark par défaut, light) définis par _∼_ 20 _tokens_ de couleur chacun, injectés en variables CSS; _∼_ 830 lignes de CSS pour les cartes, KPI, badges de sévérité et statut, fil d’Ariane du wizard, héros de login; icônes Material dans la sidebar; libellés français avec tables de traduction des statuts et sévérités. 

### **13.4 Choix ergonomiques notables** 

Transparence de l’IA (confiance et raison affichées par groupe), portes de sortie systématiques (« Passer », « Ignorer » à chaque étape IA), friction placée sur l’irréversible (double confirmation avec message explicite « cette action écrase la table »), feedback continu (spinners, barre de progression, toasts), pagination des listes longues. 

## **14 Gestion des données** 

### **14.1 Modèle de données observé** 

Le DDL n’étant pas fourni, les structures ci-dessous sont reconstituées à partir des ordres `INSERT` , `SELECT` et `UPDATE` du code — elles sont donc exactes pour les colonnes effectivement utilisées. 

Identifiants de corrélation : `run_id` horodaté préfixé selon le chemin ( `WIZ-` , `CORTEX-DEDUP-` ); identifiants d’anomalies `{IMP|DB}-{ligne}-{règle}-{n}` ; corrections `COR-nnn` ; règles personnalisées `Cnnn` . 

### **14.2 Référentiel SIRENE** 

Le Marketplace est référencé par son nom complet de _share_ — 

```
FRENCH_NATIONAL_IDENTIFICATION_SYSTEM_OF_DIRECTORY_...
```

— avec deux vues : `V_UNITE_LEGALE` et `V_ETABLISSEMENT` (jointure siège : `SIRET = SIREN || NIC_SIEGE` ). Trois modes d’accès : cache par lots (tous les SIREN de `DIM_ACCOUNT` en une requête), _lookup_ unitaire, et jointure d’enrichissement à la demande. **La table** **`DIM_SIRENE` mentionnée dans la documentation initiale n’existe pas dans le code.** 

Page 16 / 23 

|**Table**|**Colonnes utilisées par le code**|
|---|---|
|`DQ_FINDINGS`|id, account_id, company_name, severity, status, rule_id, feld, feld_label, feld_value,<br>expected_value, fnding_type, created_at|
|`DQ_CORRECTIONS`|id, anomaly_id, account_id, company_name, feld, feld_value, expected_value,<br>rule_id, action, rejection_reason, correction_status|
|`DQ_CUSTOM_RULES`|id (C001...), name, description, target_feld, rule_type, pattern, severity, is_active,<br>created_at|
|`DQ_DEDUP_RESULTS`|run_id, source_table, original_count, clean_count, removed_count, dedup_keys,<br>strategy, fuzzy_threshold|
|`DQ_SCORING`|run_id, account_id, row_num, score, rules_passed, rules_total, fags —_jamais ali-_<br>_mentée par le code_|
|`DQ_AUDIT_LOG`|action, detail, user_name, created_at|
|`DQ_STAGING_IMPORT`(+`_CLEAN`)|Colonnes dynamiques du dataset;`_CLEAN`est une table transiente recréée à chaque<br>dédoublonnage SQL|



Table 13 – Tables du schéma `DATA_QUALITY` telles qu’utilisées 

### **14.3 Flux d’écriture** 

Toutes les écritures passent par `_sf_execute` avec paramètres nommés. Trois flux modifient l’état : (1) corrections (INSERT `DQ_CORRECTIONS` + UPDATE `DQ_FINDINGS` + UPDATE conditionnel de `DIM_ACCOUNT` ); (2) cleaning (écrasement de la table source par `write_pandas overwrite=True` après double confirmation); (3) référentiel de règles (CRUD `DQ_CUSTOM_RULES` ). Chaque flux invalide les caches concernés ( `load_dq_findings.clear()` , etc.) et journalise. 

## **15 Traitements principaux et logique métier** 

### **15.1 Chaîne de traitement réelle** 

```
Import(tableoufichier),mapping(alias+Cortex),
dédoublonnage3phases,staging(write_pandas),
règlesR01–R08+custom,croisementINSEE,
scores+SLA,résolutionenmasse,
DQ_CORRECTIONS+UPDATEDIM_ACCOUNT+audit
```

### **15.2 Détails métier remarquables (vérifiés)** 

- **TVA calculée** : pour un compte FR au SIREN valide sans TVA, l’anomalie propose la TVA attendue, calculée par (12 + 3 _×_ (SIREN mod 97)) mod 97. **Exception codée** : les _collectivités publiques_ (SIREN commençant par 1 ou 2) sont exclues du calcul — la fonction retourne une chaîne vide plutôt qu’une TVA erronée, car ces entités suivent des règles d’attribution différentes de la formule INSEE générique. Sur les entreprises privées, la correction acceptée peut être écrite telle quelle dans le CRM. 

- **Normalisation de pays** : pays vide, « FRANCE », « FRA », ville en « ...CEDEX » ou contenant un code postal à 5 chiffres _⇒_ compte traité comme français. 

- **Extraction de forme juridique** : regex des sigles (SA, SAS, SASU, SARL, EURL, SCI, SNC, GIE...) appliquée au nom commercial avant de pénaliser R07. 

- **Anti-double-pénalité** : R03 n’est évaluée que si R01 et R02 passent; au scoring, R04/R06 ne comptent que si la valeur est présente. 

- **Comparaisons INSEE tolérantes** : raison sociale par inclusion croisée des chaînes normalisées, adresse par préfixes de 20 caractères, NAF insensible aux points. 

- **SLA et e-facturation** : % de comptes conformes par règle, R08 = comptes sans échec R01/R02/R03. 

Page 17 / 23 

### **15.3 Ingénierie de prompt** 

Patron commun aux quatre usages Cortex : rôle + critères explicites + données sérialisées en JSON + **format de sortie imposé avec exemple** ; côté application, extraction tolérante ( `“‘json` , `re.search` du premier tableau/objet), `json.loads` sous `try/except` , validation contre les données réelles et repli déterministe. Le prompt de fusion contraint champ par champ (SIREN 9 chiffres, SIRET 14, nom complet, adresse complète, NAF XXXXZ). 

## **16 Gestion des erreurs et validation des données** 

### **16.1 Ce qui est robuste** 

- **Import de fichiers** : essais multi-encodages et multi-séparateurs, lignes malformées ignorées, messages d’erreur explicites en français. 

- **Sorties LLM** : chaque appel Cortex est sous `try/except` avec extraction tolérante du JSON et un repli déterministe documenté (mapping vide, suppression simple des doublons, heuristique de clé de jointure). 

- **Login** : validation des champs, test `SELECT 1` , exception affichée à l’utilisateur. 

- **Staging** : `write_pandas` avec repli en `cursor.executemany(...)` **paramétré** ( _bind variables_ `%s` ) — l’ancien fallback par interpolation SQL avec apostrophes doublées a été remplacé. 

### **16.2 Le point faible : la politique** **_best-effort_** 

`_sf_query` retourne un DataFrame vide et `_sf_execute` ne fait rien en cas d’exception, _sans remonter l’erreur_ : 

Listing 2 – Absorption silencieuse des erreurs 

```
def_sf_execute (sql ,params = None ):
conn=_get_conn ()
ifconnisNone :
return
try :
conn . cursor (). execute (sql ,paramsor{})
exceptException :
pass#é critureperduesanssignal
```

Conséquences concrètes : une correction, une entrée d’audit ou un résultat de dédoublonnage peuvent être silencieusement perdus (perte de réseau, warehouse suspendu, droit manquant) alors que l’interface affiche un succès — l’état de session est mis à jour avant l’écriture. De même, une table vide et une erreur de lecture sont indistinguables. C’est le principal axe de durcissement identifié (cf. §23). 

## **17 Sécurité et protection des données** 

### **17.1 Points forts vérifiés** 

### **17.2 Points de vigilance (corrigés et précisés)** 

1. **SSO externalbrowser supporté** : le formulaire de login propose une radio _Password/SSO_ . En mode SSO, `authenticator="externalbrowser"` déclenche l’authentification par l’IdP configuré côté compte Snowflake, et **aucun mot de passe n’est stocké en session** . En mode Password, le mot de passe reste en clair dans `st.session_state` (nécessaire à la reconstruction de la connexion entre re-runs) — acceptable en mémoire serveur, mais l’usage du mode SSO est recommandé en production. 

Page 18 / 23 

|**Mesure**|**Vérifcation dans le code**|
|---|---|
|Confdentialité_by design_|Cortex en SQL natif; aucune bibliothèque HTTP, aucun appel sortant hors Snowfake|
|DML paramétré|Tous les INSERT/UPDATE/DELETE utilisent`%(x)s`— pas d’injection par les écritures|
|Échappement des prompts|Dollar-quoting`$$...$$`(mapping, clé de jointure) ou doublement des apostrophes (doublons,<br>fusion, recherches INSEE)|
|MFA TOTP|Supporté nativement (paramètre`passcode`) — mais_optionnel_|
|Audit|Chaque action signifcative journalisée avec l’utilisateur de session|
|Double confrmation|Sur l’écrasement de table (cleaning) et le rejet groupé|



Table 14 – Mesures de sécurité en place 

2. **MFA optionnel en mode Password** : le champ TOTP peut être laissé vide; l’exigence de MFA relève donc de la politique du compte Snowflake, pas de l’application. Le mode SSO contourne cette question, l’IdP portant l’authentification forte. 

3. **Interpolations résiduelles en lecture** : les SELECT interpolent des valeurs (SIREN de `lookup_sirene` , `run_id` , noms de tables, listes `IN` ) avec un échappement partiel; le risque est faible (valeurs souvent validées en amont, droits de lecture) mais l’uniformisation en requêtes paramétrées reste souhaitable. 

4. **Prompt injection par les données** : l’échappement protège la syntaxe SQL, pas la sémantique du prompt — un enregistrement contenant des instructions adverses peut influencer les groupes de doublons ou la fusion. Les garde-fous existants (validation des indices, confirmation humaine) limitent l’impact. 

5. **Compte de démonstration pré-rempli** : `SNOWADMIN` et le compte de démo sont proposés par défaut dans le formulaire; à remplacer par un rôle applicatif à privilèges minimaux en production. 

6. **Écriture en retour dans la source** : l’acceptation d’une correction peut mettre à jour `DIM_ACCOUNT` , et le cleaning peut écraser la table — pouvoir assumé et confirmé, mais qui justifie un RBAC strict sur ces tables. 

## **18 Performances et optimisations** 

### **18.1 Optimisations vérifiées dans le code** 

- **Cache gradué** : `st.cache_resource` pour la connexion; `st.cache_data` avec TTL 30 s (audit), 60 s (règles, scoring), 120 s (recherche INSEE par nom), **300 s pour les findings** (auparavant 60 s), 300 s (comptes, cache SIRENE, mapping IA), 600 s (listes de bases). Le chargement des findings a par ailleurs été durci : `show_spinner=False` pour ne pas polluer l’UI, **sélection de colonnes explicite** (fini le `SELECT *` ) et **`LIMIT 500`** (auparavant 2 000). Invalidation ciblée après chaque écriture. 

- **Croisement INSEE par lots** : tous les SIREN du référentiel chargés en une requête `IN (...)` , lookup unitaire seulement en cache-miss. 

- **Dédoublonnage ensembliste** : `ROW_NUMBER()` fenêtré côté Snowflake, normalisation en SQL, table transiente. 

- **Chargement en masse** : `write_pandas` ( `auto_create_table` , `overwrite` ) avec repli borné. 

- **Garde-fous** : `LIMIT 5000` (tables), 2 000 (findings), 100 (audit); pagination de l’UI. 

### **18.2 Points de contention (analyse du code)** 

Page 19 / 23 

|**Contention**|**Constat dans le code**|**Piste**|
|---|---|---|
|Moteur de règles Python|`iterrows()`ligne à ligne; coût linéaire en<br>Python, plus les lookups INSEE en cache-miss|Vectoriser (regex pandas) ou basculer sur le<br>chemin SQL/SP pour les gros volumes|
|Dédoublonnage Cortex|Tous les enregistrements sérialisés dans un seul<br>prompt; fusion = un appel par groupe|_Blocking_SQL préalable, n’envoyer que les<br>paires candidates|
|`LIMIT 5000`|Les tables sont tronquées à 5 000 lignes_silen-_<br>_cieusement_: au-delà, l’analyse est partielle sans<br>avertissement|Avertir l’utilisateur, paginer ou traiter côté SQL|
|Progression cosmétique|L’étape 4 anime la barre avec<br>`time.sleep(0.25)`avant l’exécution réelle|Progression liée au traitement efectif|
|Score par ligne|Seconde passe`iterrows()`complète après<br>l’analyse|Fusionner analyse et scoring en une passe|



Table 15 – Contentions identifiées et pistes 

## **19 Difficultés rencontrées et solutions apportées** 

Reconstituées à partir des choix visibles dans le code — chaque mécanisme répond à un problème concret : 

|**Difculté**|**Solution codée**|
|---|---|
|Fichiers clients hétérogènes (encodages, séparateurs, en-têtes<br>décalés)|Lecture par essais successifs 4 encodages_×_4 séparateurs,<br>heuristique d’en-tête Excel,`on_bad_lines="skip"`|
|En-têtes de colonnes imprévisibles|Mapping hybride :_∼_60 alias déterministes, puis Cortex avec<br>validation stricte de la sortie|
|Sorties LLM non fables|Format imposé + extraction tolérante + validation + repli<br>déterministe à chaque usage|
|Doublons « fous » non détectables par égalité|Deux moteurs complémentaires : clés normalisées (SQL/pan-<br>das) et groupes Cortex confrmés par l’humain|
|Croiser 29,6 M d’entreprises sans latence|Cache SIRENE par lots + lookups unitaires en repli, TTL<br>300 s|
|Score naïf pénalisant l’optionnel et comptant double|Logique d’applicabilité (R03 conditionnelle, R04/R06 si<br>valeur, R07 extractible du nom)|
|Risque d’écrasement de données|Double confrmation explicite, corrections tracées, audit sys-<br>tématique|
|Re-runs Streamlit coûteux|Cache gradué par TTL + invalidation ciblée après écriture|



Table 16 – Difficultés et solutions 

## **20 Procédure d’installation et de déploiement** 

### **20.1 Prérequis** 

Compte Snowflake avec warehouse (défaut `COMPUTE_WH` ), base `QUALITY_TEST` initialisée (tables `DATA_QUALITY` + _stored procedure_ ), abonnement au dataset Marketplace SIRENE, Cortex activé avec `mistral-large2` ; Python 3.11. 

### **20.2 Installation et lancement** 

Listing 3 – Installation 

```
pipinstall-rrequirements .txt
```

Page 20 / 23 

```
#InitialisationSnowflake:appliquerleDDLdessch é mas
#COMMERCIAL_DATAetDATA_QUALITYsurlecomptecible
streamlitrunapp.py
```

**Aucun fichier de configuration n’est requis** : la connexion (compte, utilisateur, mot de passe + TOTP _ou_ SSO externalbrowser, warehouse) est saisie dans le formulaire de login. La table par défaut ( `DIM_ACCOUNT` dans `QUALITY_TEST.COMMERCIAL_DATA` ) est modifiable via la sidebar. 

#### **Hypothèse** 

Un fichier `requirements.txt` figure dans le dépôt et fige les dépendances (streamlit, snowflakeconnector-python, pandas, plotly, libraries de parsing PDF/DOCX pour l’import IA des règles). Le mode d’hébergement cible reste en revanche ambigu : le docstring ( _Streamlit in Snowflake_ ) suggère un déploiement natif dans Snowflake, mais le code utilise `snowflake.connector` avec authentification (password ou SSO), caractéristique d’une exécution _externe_ à Snowflake — les deux modes sont possibles moyennant l’adaptation de la connexion. 

## **21 Tests réalisés** 

Aucun test automatisé n’accompagne `app.py` (pas de dossier `tests/` , aucun framework importé). Constat inchangé et d’autant plus notable que le moteur de règles est du Python applicatif, donc _directement testable_ : les validateurs purs ( `_valid_siren` , `_valid_vat_fr` , `_vat_from_siren` , `_extract_legal_form` , `_is_french_city` ), le moteur `analyze_uploaded_dataframe` et la logique d’applicabilité du scoring se prêtent à des tests unitaires sans aucune dépendance Snowflake. Priorités recommandées : (1) validateurs et algorithme de clé TVA; (2) matrice de cas du moteur de règles (sévérités, filtre France, DUP); (3) applicabilité du scoring; (4) parseurs de sorties Cortex sur réponses malformées; (5) dédoublonnage pandas (stratégies, clés composites). 

## **22 Limites actuelles du projet** 

1. **Volumétrie** : `LIMIT 5000` silencieux sur le chargement des tables — au-delà, analyse partielle sans avertissement; moteur de règles en `iterrows()` . 

2. **Fiabilité des écritures** : politique _best-effort_ (exceptions avalées) — des écritures peuvent être perdues sans signal. 

3. **Monolithe** : 5 416 lignes mêlant UI, logique métier et accès données; _∼_ 830 lignes de CSS dans le même fichier. 

4. **Scoring non persisté** : `DQ_SCORING` et `persist_scoring` existent mais ne sont jamais utilisés — pas d’historique de scores. 

5. **Sujet « Adresse » encore vitrine** : sélectionnable dans le wizard et référencé ( `ADDR` ), mais aucun contrôle ne l’émet. _Le sujet « Web » n’est en revanche plus une vitrine_ : il est implémenté par le _Web Verification Agent_ (§11.8). 

6. **Sécurité** : SSO `externalbrowser` disponible; en mode Password, MFA optionnel et mot de passe en session. 

7. **Périmètre France** : les comptes non français sont filtrés, pas contrôlés. 

8. **Pas de monitoring continu** : analyses à la demande uniquement. 

9. **Non-déterminisme IA** : les groupes Cortex peuvent varier d’une exécution à l’autre; atténué par la confirmation humaine. 

Page 21 / 23 

## **23 Améliorations possibles** 

1. **Durcir la couche d’accès** : remonter les erreurs de `_sf_execute` (retour booléen + `st.error` ), écrire _avant_ de mettre à jour l’état de session. 

2. **Lever le plafond des 5 000 lignes** : avertissement explicite, pagination, ou bascule automatique sur le chemin SQL/SP pour les gros volumes. 

3. **Activer le scoring persisté** : brancher `persist_scoring` (le `run_id` existe déjà) pour historiser la qualité et alimenter la tendance du dashboard. 

4. **Blocking avant Cortex** : pré-grouper les candidats en SQL et ne soumettre que les paires plausibles. 

5. **Compléter ou retirer le sujet Adresse** : implémenter la règle `ADDR` ou masquer le sujet; « Web » est déjà couvert par l’agent. 

6. **Modulariser** : extraire `rules.py` , `sirene.py` , `cortex.py` , `dal.py` et le CSS — prérequis naturel aux tests unitaires. 

7. **Rendre le SSO obligatoire en production** : le mode SSO `externalbrowser` existe déjà; il reste à retirer le mode Password en production pour éliminer complètement la conservation du mot de passe en session. 

8. **Uniformiser le paramétrage** des SELECT restants. 

9. **Vectoriser** le moteur de règles (regex pandas) et fusionner analyse + scoring en une passe. 

## **24 Analyse critique : constats issus de la revue de code** 

Cette section confronte la documentation initiale au code et consolide les constats (code mort, incohérences, fonctionnalités incomplètes). 

|**#**|**Constat vérifé dans le code**|**Impact**|
|---|---|---|
|1|Le moteur principal des règles est**Python ligne à ligne**, pas la_stored procedure_(chemin batch secondaire,<br>onglet dédié) — l’ambiguïté documentaire est levée|Structurant|
|2|**Code mort**:`persist_scoring`et`load_scoring`jamais appelés; la table`DQ_SCORING`n’est<br>jamais alimentée|Moyen|
|3|**Vestige confrmé**:`fuzzy_threshold`toujours transmis à 0.0 — reliquat d’une approche_fuzzy mat-_<br>_ching_antérieure|Faible|
|4|Le sujet « Web » est couvert par l’agent`_web_verify_finding`(§11.8); « Adresse » (`ADDR`) reste<br>**sans règle émettrice**|Faible|
|5|**Exceptions avalées**dans`_sf_query`/`_sf_execute`: pertes d’écriture silencieuses possibles, table<br>vide indistinguable d’une erreur|Élevé|
|6|`LIMIT 5000`silencieux : analyse partielle sur les grandes tables sans avertissement|Élevé|
|7|La documentation initiale surestimait deux risques, infrmés par le code : le DML est**paramétré**et les<br>prompts Cortex sont**échappés**; restent les interpolations de SELECT et la prompt injection sémantique|Positif|
|8|Login à**deux modes**: Password (TOTP optionnel)_ou_SSO`externalbrowser`— l’écart avec la docu-<br>mentation initiale est levé|Positif|
|9|Mot de passe Snowfake conservé en clair dans`st.session_state`|Moyen|
|10|`DIM_SIRENE`(documentée) absente du code; accès SIRENE exclusivement via le Marketplace|Faible|
|11|Progression du wizard partiellement**cosmétique**(`time.sleep`avant l’exécution réelle)|Faible|
|12|Divergence de nommage : produit_Léon_, code interne_Qualitix_(docstring, préfxes CSS`qx-`); le logo est<br>une illustration SVG (personnage) et non plus le sigle « Q » historique|Faible|



Table 17 – Synthèse de la revue de code 

Page 22 / 23 

#### **Point clé** 

Points forts confirmés par la revue : la logique d’applicabilité du scoring (implémentée exactement comme documentée), la gouvernance human-in-the-loop avec portes de sortie à chaque étape IA, la robustesse des parseurs de sorties LLM (format imposé, extraction tolérante, validation, repli), le DML systématiquement paramétré et le cache gradué par volatilité. La qualité d’ingénierie «produit» (design system, libellés français, feedback continu) est nettement supérieure à ce que la documentation laissait paraître. 

## **25 Conclusion** 

La revue du code confirme la thèse architecturale de Léon : **la plateforme data est aussi la plateforme d’IA** . Le **dédoublonnage repose sur un pipeline déterministe en trois phases** , l’IA est concentrée sur **huit tâches sémantiques** bien définies, dont deux **agents** au moment de la résolution (auto-correction multi-stratégie, vérification web par récupération et jugement LLM), un **Cortex Search Service** pour la recherche sémantique SIRENE (~13M sièges, embeddings arctic-embed-l-v2.0), et l’ **authentification supporte le SSO** . Le système est hybride : Snowflake porte l’ensembliste (staging, référentiel SIRENE, LLM natif) et Python porte le conditionnel (règles riches, heuristiques françaises, scoring d’applicabilité, TVA calculée avec exception pour les collectivités publiques). 

L’usage de l’IA est discipliné : sorties contraintes, validées et toujours doublées d’un repli déterministe, sous confirmation humaine. Deux choix de conception structurent la place du LLM : les tâches génératives à sortie structurée (dédoublonnage, fusion) sont _déléguées à un pipeline déterministe_ pour la reproductibilité et le coût, tandis que les tâches réellement adaptées au LLM (raisonnement, jugement sur des indices textuels) sont _portées par les agents_ . La sécurité des écritures (DML paramétré, staging `executemany` paramétré, SSO, double confirmation, audit) est bonne. 

Les axes de consolidation sont précis et hiérarchisés : remonter les erreurs de la couche d’accès (fiabilité des écritures), lever le plafond silencieux des 5 000 lignes (exactitude des analyses), activer le scoring persisté (historisation), compléter ou retirer les sujets vitrines (honnêteté fonctionnelle), puis modulariser et tester — le moteur de règles étant du Python pur, la mise sous tests est immédiate. Aucun de ces chantiers ne remet en cause l’architecture : ils en sont le prolongement naturel. 

Page 23 / 23 

