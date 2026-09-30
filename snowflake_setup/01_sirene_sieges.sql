-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.SIRENE_SIEGES
-- Description: Table préparée à partir du registre SIRENE (INSEE).
--              Une ligne par SIREN (siège uniquement, ~29.6M lignes).
--              Source : FRENCH_NATIONAL_IDENTIFICATION_SYSTEM_OF_DIRECTORY_OF_BUSINESSES_AND_THEIR_ESTABLISHMENTS.SIRENE
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.SIRENE_SIEGES (
    SIREN                VARCHAR(16777216),
    DENOMINATION         VARCHAR(16777216),
    NAF                  VARCHAR(16777216),
    STATUT               VARCHAR(16777216),
    SIRET_SIEGE          VARCHAR(16777216),
    CATEGORIE_JURIDIQUE  VARCHAR(16777216),
    VILLE                VARCHAR(200),
    CODE_POSTAL          VARCHAR(16777216),
    ADRESSE              VARCHAR(16777216)
);
