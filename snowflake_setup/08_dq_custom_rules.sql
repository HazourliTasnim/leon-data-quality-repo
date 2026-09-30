-- =============================================================================
-- Table: QUALITY_TEST.DATA_QUALITY.DQ_CUSTOM_RULES
-- Description: Règles de validation personnalisées (regex, etc.).
--              2 lignes actives.
-- =============================================================================

CREATE OR REPLACE TABLE QUALITY_TEST.DATA_QUALITY.DQ_CUSTOM_RULES (
    ID           VARCHAR(20) NOT NULL PRIMARY KEY,
    NAME         VARCHAR(255) NOT NULL,
    DESCRIPTION  VARCHAR(1000),
    TARGET_FIELD VARCHAR(100) NOT NULL,
    RULE_TYPE    VARCHAR(20) DEFAULT 'regex',
    PATTERN      VARCHAR(500),
    SEVERITY     VARCHAR(10) DEFAULT 'MEDIUM',
    IS_ACTIVE    BOOLEAN DEFAULT TRUE,
    CREATED_BY   VARCHAR(255) DEFAULT CURRENT_USER(),
    CREATED_AT   TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP()
);
