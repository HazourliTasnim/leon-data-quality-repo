-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_SESSION_CACHE
-- Description: Cache de session pour stocker les résultats d'analyse
--              intermédiaires (données, anomalies, corrections en VARIANT).
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_SESSION_CACHE (
    SESSION_ID       VARCHAR(16777216) DEFAULT UUID_STRING(),
    USER_NAME        VARCHAR(16777216),
    FILENAME         VARCHAR(16777216),
    ANALYSIS_DATA    VARIANT,
    ANOMALIES_DATA   VARIANT,
    CORRECTIONS_DATA VARIANT,
    CREATED_AT       TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP(),
    EXPIRES_AT       TIMESTAMP_NTZ(9)
);
