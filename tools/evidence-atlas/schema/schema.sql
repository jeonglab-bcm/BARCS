-- BARCS evidence atlas, schema version 2.
-- Derived database: built from an approved collection directory, never edited in place.
-- Source rows are immutable once inserted; the review history is append-only.

PRAGMA foreign_keys = ON;

CREATE TABLE schema_meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
INSERT INTO schema_meta (key, value) VALUES ('schema_version', '2');

-- Scope vocabulary. Only rows with permitted = 1 can ever reach an export.
CREATE TABLE scope_category (
  name      TEXT PRIMARY KEY,
  permitted INTEGER NOT NULL CHECK (permitted IN (0, 1))
);
INSERT INTO scope_category (name, permitted) VALUES
  ('developmental_biology', 1),
  ('cell_biology', 1),
  ('pathogen', 0),
  ('host_susceptibility', 0),
  ('transmission', 0),
  ('virulence', 0),
  ('immune_evasion', 0),
  ('toxin', 0),
  ('security_sensitive', 0),
  ('uncertain', 0);

CREATE TABLE source (
  id                TEXT PRIMARY KEY CHECK (id GLOB 'src_*' AND substr(id, 5) NOT GLOB '*[^0-9a-f]*' AND length(id) = 16),
  kind              TEXT NOT NULL CHECK (kind IN ('publication', 'archive')),
  identifier_scheme TEXT NOT NULL CHECK (identifier_scheme IN ('doi', 'pmid', 'url', 'fixture')),
  identifier        TEXT NOT NULL,
  citation          TEXT NOT NULL,
  url               TEXT NOT NULL CHECK (url GLOB 'https://*'),
  accessed          TEXT NOT NULL CHECK (accessed GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
  UNIQUE (identifier_scheme, identifier)
);

CREATE TABLE dataset (
  id           TEXT PRIMARY KEY CHECK (id GLOB 'ds_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  accession    TEXT NOT NULL,
  version      TEXT,                       -- NULL = unknown
  described_by TEXT NOT NULL REFERENCES source (id),
  UNIQUE (accession, version)
);

CREATE TABLE study (
  id                TEXT PRIMARY KEY CHECK (id GLOB 'st_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  dataset_id        TEXT NOT NULL REFERENCES dataset (id),
  title             TEXT NOT NULL,
  scope_category    TEXT NOT NULL REFERENCES scope_category (name),
  archive_ref       TEXT NOT NULL,
  archive_sha256    TEXT NOT NULL CHECK (length(archive_sha256) = 64),
  validation_status TEXT NOT NULL CHECK (validation_status IN ('not_validated', 'validated', 'validation_failed')),
  organism          TEXT NOT NULL
);

CREATE TABLE analysis (
  id              TEXT PRIMARY KEY CHECK (id GLOB 'an_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  study_id        TEXT NOT NULL REFERENCES study (id),
  label           TEXT NOT NULL,
  method          TEXT NOT NULL,
  method_version  TEXT NOT NULL,
  fdr_threshold   REAL CHECK (fdr_threshold IS NULL OR (fdr_threshold > 0 AND fdr_threshold < 1)),
  artifact_ref    TEXT NOT NULL,
  artifact_sha256 TEXT NOT NULL CHECK (length(artifact_sha256) = 64)
);

-- A reviewed result from one analysis. Never merged across studies, even for the same gene.
CREATE TABLE observation (
  id               TEXT PRIMARY KEY CHECK (id GLOB 'ob_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  analysis_id      TEXT NOT NULL REFERENCES analysis (id),
  gene_symbol      TEXT NOT NULL,
  gene_id          TEXT CHECK (gene_id IS NULL OR (gene_id GLOB 'HGNC:[0-9]*' AND substr(gene_id, 6) NOT GLOB '*[^0-9]*') OR (gene_id GLOB 'MGI:[0-9]*' AND substr(gene_id, 5) NOT GLOB '*[^0-9]*')),
  gene_id_status   TEXT NOT NULL CHECK (gene_id_status IN ('mapped', 'synonym', 'ambiguous', 'unmapped')),
  gene_key         TEXT GENERATED ALWAYS AS (CASE WHEN gene_id IS NOT NULL AND gene_id_status IN ('mapped', 'synonym')
                                                THEN gene_id ELSE 'symbol:' || gene_symbol END) VIRTUAL,
  source_wording   TEXT NOT NULL,          -- as archived; reviewer wording lives in review.approved_wording
  estimate         REAL,                   -- NULL = unknown
  estimate_meaning TEXT,                   -- what a positive estimate means, as archived; NULL = unknown
  p_value          REAL CHECK (p_value IS NULL OR (p_value >= 0 AND p_value <= 1)),
  fdr              REAL CHECK (fdr IS NULL OR (fdr >= 0 AND fdr <= 1)),
  n_elements       INTEGER CHECK (n_elements IS NULL OR n_elements >= 1),
  direction        TEXT CHECK (direction IS NULL OR direction IN ('enriched', 'depleted')),
  limitations      TEXT
);

-- An author statement. Independent of any statistical assessment.
CREATE TABLE claim (
  id              TEXT PRIMARY KEY CHECK (id GLOB 'cl_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  source_id       TEXT NOT NULL REFERENCES source (id),
  study_id        TEXT NOT NULL REFERENCES study (id),
  gene_symbol      TEXT NOT NULL,
  gene_id          TEXT CHECK (gene_id IS NULL OR (gene_id GLOB 'HGNC:[0-9]*' AND substr(gene_id, 6) NOT GLOB '*[^0-9]*') OR (gene_id GLOB 'MGI:[0-9]*' AND substr(gene_id, 5) NOT GLOB '*[^0-9]*')),
  gene_id_status   TEXT NOT NULL CHECK (gene_id_status IN ('mapped', 'synonym', 'ambiguous', 'unmapped')),
  gene_key         TEXT GENERATED ALWAYS AS (CASE WHEN gene_id IS NOT NULL AND gene_id_status IN ('mapped', 'synonym')
                                                THEN gene_id ELSE 'symbol:' || gene_symbol END) VIRTUAL,
  source_wording  TEXT NOT NULL,           -- verbatim
  source_location TEXT NOT NULL
);

CREATE TABLE annotation (
  id                 TEXT PRIMARY KEY CHECK (id GLOB 'at_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  gene_symbol      TEXT NOT NULL,
  gene_id          TEXT CHECK (gene_id IS NULL OR (gene_id GLOB 'HGNC:[0-9]*' AND substr(gene_id, 6) NOT GLOB '*[^0-9]*') OR (gene_id GLOB 'MGI:[0-9]*' AND substr(gene_id, 5) NOT GLOB '*[^0-9]*')),
  gene_id_status   TEXT NOT NULL CHECK (gene_id_status IN ('mapped', 'synonym', 'ambiguous', 'unmapped')),
  gene_key         TEXT GENERATED ALWAYS AS (CASE WHEN gene_id IS NOT NULL AND gene_id_status IN ('mapped', 'synonym')
                                                THEN gene_id ELSE 'symbol:' || gene_symbol END) VIRTUAL,
  vocabulary         TEXT NOT NULL,
  vocabulary_version TEXT NOT NULL,
  term_id            TEXT NOT NULL,
  term_label         TEXT NOT NULL,
  attribution        TEXT NOT NULL,
  origin             TEXT NOT NULL CHECK (origin IN ('curated', 'model_generated')),
  UNIQUE (gene_symbol, vocabulary, vocabulary_version, term_id)
);

-- The BARCS project's comparison of its reanalysis with the paper (meta.json). Not an author claim.
CREATE TABLE assessment (
  id              TEXT PRIMARY KEY CHECK (id GLOB 'as_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  study_id        TEXT NOT NULL REFERENCES study (id),
  agreement       TEXT CHECK (agreement IS NULL OR agreement IN ('agree', 'partial', 'differ')),
  verdict_wording TEXT NOT NULL,
  assessed_by     TEXT NOT NULL,
  archive_ref     TEXT NOT NULL,
  archive_sha256  TEXT NOT NULL CHECK (length(archive_sha256) = 64)
);

CREATE VIEW record_index AS
  SELECT 'source' AS type, id FROM source
  UNION ALL SELECT 'dataset', id FROM dataset
  UNION ALL SELECT 'study', id FROM study
  UNION ALL SELECT 'analysis', id FROM analysis
  UNION ALL SELECT 'observation', id FROM observation
  UNION ALL SELECT 'claim', id FROM claim
  UNION ALL SELECT 'annotation', id FROM annotation
  UNION ALL SELECT 'assessment', id FROM assessment;

CREATE TABLE review (
  id                               TEXT PRIMARY KEY CHECK (id GLOB 'rv_*' AND substr(id, 4) NOT GLOB '*[^0-9a-f]*' AND length(id) = 15),
  seq                              INTEGER NOT NULL UNIQUE,  -- line number in reviews.jsonl
  target_type                      TEXT NOT NULL CHECK (target_type IN ('study', 'observation', 'claim', 'annotation', 'assessment')),
  target_id                        TEXT NOT NULL,
  revision                         INTEGER NOT NULL CHECK (revision >= 1),
  reviewer                         TEXT NOT NULL,
  timestamp                        TEXT NOT NULL,
  decision                         TEXT NOT NULL CHECK (decision IN ('approve', 'needs_changes', 'reject', 'uncertain')),
  rationale                        TEXT NOT NULL,
  check_source_identity            TEXT NOT NULL,
  check_wording                    TEXT NOT NULL,
  check_measurement_interpretation TEXT NOT NULL,
  check_statistical_representation TEXT NOT NULL,
  check_scope                      TEXT NOT NULL,
  approved_wording                 TEXT,
  scope_decision                   TEXT CHECK (scope_decision IS NULL OR scope_decision IN ('in_scope', 'out_of_scope', 'uncertain')),
  prev_hash                        TEXT NOT NULL CHECK (length(prev_hash) = 64),
  entry_hash                       TEXT NOT NULL UNIQUE CHECK (length(entry_hash) = 64),
  UNIQUE (target_type, target_id, revision)
);

CREATE TRIGGER review_target_exists BEFORE INSERT ON review
WHEN NOT EXISTS (SELECT 1 FROM record_index WHERE type = NEW.target_type AND id = NEW.target_id)
BEGIN SELECT RAISE(ABORT, 'review target does not exist'); END;

-- Immutability: source records and review history cannot be changed or removed.
CREATE TRIGGER review_no_update BEFORE UPDATE ON review BEGIN SELECT RAISE(ABORT, 'review history is append-only'); END;
CREATE TRIGGER review_no_delete BEFORE DELETE ON review BEGIN SELECT RAISE(ABORT, 'review history is append-only'); END;
CREATE TRIGGER source_no_update BEFORE UPDATE ON source BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER dataset_no_update BEFORE UPDATE ON dataset BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER study_no_update BEFORE UPDATE ON study BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER analysis_no_update BEFORE UPDATE ON analysis BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER observation_no_update BEFORE UPDATE ON observation BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER claim_no_update BEFORE UPDATE ON claim BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER assessment_no_update BEFORE UPDATE ON assessment BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;
CREATE TRIGGER annotation_no_update BEFORE UPDATE ON annotation BEGIN SELECT RAISE(ABORT, 'source records are immutable'); END;

-- Provenance relationships. Evidence references, not assertions of causality.
CREATE VIEW provenance_edge AS
  SELECT 'dataset' AS subject_type, id AS subject_id, 'described_by' AS relation, 'source' AS object_type, described_by AS object_id FROM dataset
  UNION ALL SELECT 'study', id, 'references', 'dataset', dataset_id FROM study
  UNION ALL SELECT 'analysis', id, 'derived_from', 'study', study_id FROM analysis
  UNION ALL SELECT 'observation', id, 'documented_by', 'analysis', analysis_id FROM observation
  UNION ALL SELECT 'claim', id, 'attributed_to', 'source', source_id FROM claim
  UNION ALL SELECT 'annotation', id, 'sourced_from', 'vocabulary', vocabulary || '@' || vocabulary_version FROM annotation
  UNION ALL SELECT 'assessment', id, 'reports_on', 'study', study_id FROM assessment
  UNION ALL SELECT 'review', id, 'assesses', target_type, target_id FROM review;

-- Eligibility (export boundary). A record is approved when every reviewer's latest
-- review of it is a full approval: decision approve, no check uncertain or missing,
-- and for a study, scope confirmed in scope. One dissenting reviewer withholds it.
CREATE VIEW review_full_approval AS
  SELECT r.*,
    CASE WHEN r.decision = 'approve'
          AND r.check_source_identity            NOT IN ('uncertain', 'missing')
          AND r.check_wording                    NOT IN ('uncertain', 'missing')
          AND r.check_measurement_interpretation NOT IN ('uncertain', 'missing')
          AND r.check_statistical_representation NOT IN ('uncertain', 'missing')
          AND r.check_scope                      NOT IN ('uncertain', 'missing')
          AND (r.target_type <> 'study' OR (r.scope_decision = 'in_scope' AND r.check_scope = 'confirmed'))
         THEN 1 ELSE 0 END AS full_approval
  FROM review r;

CREATE VIEW latest_review_per_reviewer AS
  SELECT f.* FROM review_full_approval f
  WHERE f.revision = (SELECT MAX(r2.revision) FROM review r2
                      WHERE r2.target_type = f.target_type AND r2.target_id = f.target_id
                        AND r2.reviewer = f.reviewer);

CREATE VIEW approved_record AS
  SELECT target_type, target_id FROM latest_review_per_reviewer
  GROUP BY target_type, target_id
  HAVING MIN(full_approval) = 1;

CREATE VIEW eligible_study AS
  SELECT s.* FROM study s
  JOIN approved_record a ON a.target_type = 'study' AND a.target_id = s.id
  JOIN scope_category c ON c.name = s.scope_category AND c.permitted = 1;

CREATE VIEW eligible_observation AS
  SELECT o.* FROM observation o
  JOIN approved_record a ON a.target_type = 'observation' AND a.target_id = o.id
  JOIN analysis an ON an.id = o.analysis_id
  JOIN eligible_study s ON s.id = an.study_id;

CREATE VIEW eligible_claim AS
  SELECT c.* FROM claim c
  JOIN approved_record a ON a.target_type = 'claim' AND a.target_id = c.id
  JOIN eligible_study s ON s.id = c.study_id;

CREATE VIEW eligible_gene AS
  SELECT gene_key FROM eligible_observation
  UNION SELECT gene_key FROM eligible_claim;

CREATE VIEW eligible_annotation AS
  SELECT t.* FROM annotation t
  JOIN approved_record a ON a.target_type = 'annotation' AND a.target_id = t.id
  WHERE t.gene_key IN (SELECT gene_key FROM eligible_gene);

-- Assessments are shown only for studies that contribute an exported observation or claim.
CREATE VIEW eligible_assessment AS
  SELECT x.* FROM assessment x
  JOIN approved_record a ON a.target_type = 'assessment' AND a.target_id = x.id
  JOIN eligible_study s ON s.id = x.study_id
  WHERE x.study_id IN (SELECT an.study_id FROM eligible_observation o JOIN analysis an ON an.id = o.analysis_id
                       UNION SELECT study_id FROM eligible_claim);

CREATE VIEW eligible_analysis AS
  SELECT DISTINCT an.* FROM analysis an JOIN eligible_observation o ON o.analysis_id = an.id;

CREATE VIEW eligible_dataset AS
  SELECT DISTINCT d.* FROM dataset d JOIN eligible_study s ON s.dataset_id = d.id;

CREATE VIEW eligible_source AS
  SELECT src.* FROM source src WHERE src.id IN (
    SELECT described_by FROM eligible_dataset UNION SELECT source_id FROM eligible_claim);
