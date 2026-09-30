-- =============================================================================
-- Cortex Search Service: QUALITY_TEST.DATA_QUALITY.SIRENE_COMPANY_SEARCH
-- Description: Service de recherche vectorielle sur les entreprises SIRENE.
--              Permet la recherche floue par nom d'entreprise (dénomination + ville).
--
-- Table source     : QUALITY_TEST.DATA_QUALITY.SIRENE_SIEGES
-- Colonne indexée  : SEARCH_TEXT (= DENOMINATION || ' ' || VILLE)
-- Modèle embeddings: snowflake-arctic-embed-l-v2.0
-- Refresh          : INCREMENTAL, target lag = 1 day
-- Warehouse        : COMPUTE_WH
-- Lignes indexées  : ~12.9M (lignes avec DENOMINATION non vide / non '[ND]')
-- =============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE QUALITY_TEST.DATA_QUALITY.SIRENE_COMPANY_SEARCH
    ON SEARCH_TEXT
    ATTRIBUTES SIREN, VILLE, CODE_POSTAL, STATUT
    WAREHOUSE = COMPUTE_WH
    TARGET_LAG = '1 day'
AS (
    SELECT
        SIREN           AS siren,
        DENOMINATION     AS denomination,
        CONCAT(DENOMINATION, ' ', COALESCE(VILLE, '')) AS search_text,
        VILLE            AS ville,
        CODE_POSTAL      AS code_postal,
        NAF              AS naf,
        SIRET_SIEGE      AS siret,
        CATEGORIE_JURIDIQUE AS categorie_juridique,
        ADRESSE          AS adresse,
        STATUT           AS statut
    FROM QUALITY_TEST.DATA_QUALITY.SIRENE_SIEGES
    WHERE DENOMINATION IS NOT NULL
      AND DENOMINATION != ''
      AND DENOMINATION != '[ND]'
);
