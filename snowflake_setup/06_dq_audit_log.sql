-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_AUDIT_LOG
-- Description: Journal d'audit des actions utilisateur dans l'application DQ.
--              ~430 lignes.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_AUDIT_LOG (
    ID          NUMBER(38,0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 NOORDER PRIMARY KEY,
    ACTION      VARCHAR(255),
    DETAIL      VARCHAR(1000),
    USER_NAME   VARCHAR(255),
    CREATED_AT  TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
