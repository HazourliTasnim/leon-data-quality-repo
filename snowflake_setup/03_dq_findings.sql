-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_FINDINGS
-- Description: Anomalies détectées par le moteur de qualité.
--              Chaque ligne = un problème identifié sur un champ d'un compte.
--              ~14K lignes.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_FINDINGS (
    ID              VARCHAR(50) NOT NULL PRIMARY KEY,
    ACCOUNT_ID      VARCHAR(50),
    COMPANY_NAME    VARCHAR(255),
    SEVERITY        VARCHAR(10),
    STATUS          VARCHAR(20) DEFAULT 'Open',
    SUBJECT         VARCHAR(50),
    RULE_ID         VARCHAR(10),
    FIELD           VARCHAR(100),
    FIELD_LABEL     VARCHAR(100),
    FIELD_VALUE     VARCHAR(500),
    EXPECTED_VALUE  VARCHAR(500),
    FINDING_TYPE    VARCHAR(255),
    DESCRIPTION     VARCHAR(1000),
    CREATED_AT      TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_TABLE    VARCHAR(500)
);
