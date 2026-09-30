-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_ANALYSIS_HISTORY
-- Description: Historique des exécutions d'analyse qualité.
--              Chaque ligne = un run complet avec scores et métriques.
--              ~70 lignes.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_ANALYSIS_HISTORY (
    ID              VARCHAR(16777216) DEFAULT UUID_STRING(),
    SOURCE_TABLE    VARCHAR(16777216),
    SOURCE_TYPE     VARCHAR(16777216),
    FILENAME        VARCHAR(16777216),
    TOTAL_ROWS      NUMBER(38,0),
    CLEAN_ROWS      NUMBER(38,0),
    ANOMALY_COUNT   NUMBER(38,0),
    DUPLICATES_COUNT NUMBER(38,0),
    SCORE           NUMBER(38,0),
    SCORE_PREVIOUS  NUMBER(38,0),
    RULES_APPLIED   VARCHAR(16777216),
    DURATION_S      FLOAT,
    USER_NAME       VARCHAR(16777216),
    CREATED_AT      TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
