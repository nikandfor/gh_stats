

CREATE TABLE followers (
    id      Int64,
    login   LowCardinality(String),

    f_id    Int64,
    f_login LowCardinality(String),

    ts      DateTime DEFAULT now(),

    day   Date MATERIALIZED toStartOfDay(ts),
    week  Date MATERIALIZED toStartOfWeek(ts),
    month Date MATERIALIZED toStartOfMonth(ts),
    year  Date MATERIALIZED toStartOfYear(ts),

    db_insert_time DateTime MATERIALIZED now(),
)
ENGINE MergeTree
PARTITION BY month
ORDER BY (id, f_id, ts)
;

CREATE TABLE stars (
    id      Int64,
    login   LowCardinality(String),

    repo_id Int64,
    repo    LowCardinality(String),

    f_id    Int64,
    f_login LowCardinality(String),

    ts      DateTime DEFAULT now(),

    day   Date MATERIALIZED toStartOfDay(ts),
    week  Date MATERIALIZED toStartOfWeek(ts),
    month Date MATERIALIZED toStartOfMonth(ts),
    year  Date MATERIALIZED toStartOfYear(ts),

    db_insert_time DateTime MATERIALIZED now(),
)
ENGINE MergeTree
PARTITION BY month
ORDER BY (id, repo_id, f_id, ts)
;
