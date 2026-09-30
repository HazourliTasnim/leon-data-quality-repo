-- =============================================================================
-- Table: QUALITY_TEST.COMMERCIAL_DATA.DIM_ACCOUNT
-- Description: Référentiel des comptes entreprises B2B (15 lignes).
--              Référencée par SV_QUALITIX (table logique ACCOUNTS).
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.COMMERCIAL_DATA.DIM_ACCOUNT (
    ACCOUNT_ID   VARCHAR(50) NOT NULL PRIMARY KEY,
    COMPANY_NAME VARCHAR(255),
    SIREN        VARCHAR(20),
    SIRET        VARCHAR(20),
    VAT          VARCHAR(30),
    ADDRESS      VARCHAR(500),
    NAF          VARCHAR(10),
    COUNTRY      VARCHAR(10),
    LEGAL_FORM   VARCHAR(50)
);
