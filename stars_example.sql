SELECT
    t,
    total,
    length(new) AS n_new,
    arrayFilter(e -> (NOT has(prev, e)), fs) AS new,
    arrayFilter(e -> (NOT has(fs, e)), prev) AS left
FROM (
    SELECT
        t,
        total,
        fs,
        lagInFrame(fs) OVER (ROWS 1 PRECEDING) AS prev
    FROM (
        SELECT
            toStartOfHour(ts) AS t,
            uniq(f_id) as total,
            groupUniqArray(f_login) AS fs
        FROM stars
        WHERE (login = 'filapro') AND (repo = 'unidet3d')
        GROUP BY ALL
        ORDER BY ALL
    )
)
WHERE n_new != 0 OR length(left) != 0
