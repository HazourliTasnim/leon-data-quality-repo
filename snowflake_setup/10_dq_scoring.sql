-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_SCORING
-- Description: Scores de qualité par ligne/compte pour chaque run.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_SCORING (
    ID           NUMBER(38,0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 NOORDER PRIMARY KEY,
    RUN_ID       VARCHAR(50) NOT NULL,
    ACCOUNT_ID   VARCHAR(50),
    ROW_NUM      NUMBER(38,0),
    SCORE        NUMBER(5,2),
    RULES_PASSED NUMBER(38,0),
    RULES_TOTAL  NUMBER(38,0),
    FLAGS        VARCHAR(2000),
    CREATED_AT   TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
