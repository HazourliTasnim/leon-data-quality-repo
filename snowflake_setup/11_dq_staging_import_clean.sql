-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_STAGING_IMPORT_CLEAN
-- Description: Table transient de staging pour les imports nettoyés.
-- =============================================================================

CREATE OR REPLACE TRANSIENT TABLE QUALITY_TEST.DATA_QUALITY.DQ_STAGING_IMPORT_CLEAN (
    ACCOUNT_ID   VARCHAR(50),
    COMPANY_NAME VARCHAR(255),
    SIREN        VARCHAR(20),
    SIRET        VARCHAR(20),
    VAT          VARCHAR(30),
    ADDRESS      VARCHAR(500),
    NAF          VARCHAR(10),
    COUNTRY      VARCHAR(10),
    LEGAL_FORM   VARCHAR(50),
    _RN          NUMBER(18,0)
);
