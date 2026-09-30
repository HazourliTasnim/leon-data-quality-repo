-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_CORRECTIONS
-- Description: Corrections appliquées ou rejetées pour les anomalies DQ.
--              ~2K lignes.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_CORRECTIONS (
    ID                VARCHAR(50) NOT NULL PRIMARY KEY,
    ANOMALY_ID        VARCHAR(50),
    ACCOUNT_ID        VARCHAR(50),
    COMPANY_NAME      VARCHAR(255),
    FIELD             VARCHAR(100),
    FIELD_VALUE       VARCHAR(500),
    EXPECTED_VALUE    VARCHAR(500),
    RULE_ID           VARCHAR(10),
    ACTION            VARCHAR(20),
    REJECTION_REASON  VARCHAR(500),
    CORRECTION_STATUS VARCHAR(50),
    CREATED_AT        TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
