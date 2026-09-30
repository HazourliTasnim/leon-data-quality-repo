-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_DEDUP_RESULTS
-- Description: Résultats des opérations de dédoublonnage.
--              ~78 lignes.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_DEDUP_RESULTS (
    ID               NUMBER(38,0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 NOORDER PRIMARY KEY,
    RUN_ID           VARCHAR(50) NOT NULL,
    SOURCE_TABLE     VARCHAR(255),
    ORIGINAL_COUNT   NUMBER(38,0),
    CLEAN_COUNT      NUMBER(38,0),
    REMOVED_COUNT    NUMBER(38,0),
    DEDUP_KEYS       VARCHAR(500),
    STRATEGY         VARCHAR(50),
    FUZZY_THRESHOLD  NUMBER(3,2),
    CREATED_AT       TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
