WITH t AS (
    SELECT player_id,
           EXTRACT(year FROM game_dt) AS year,
           MIN(game_dt) OVER w start_dt,
           game_dt end_dt,
           SUM(b_h) OVER w h,
           SUM(b_ab) OVER w ab,
           SUM(coalesce(b_pa, b_ab + coalesce(b_bb, 0) + coalesce(b_hp, 0) + coalesce(b_sf, 0) + coalesce(b_xi, 0))) OVER w pa,
           COUNT(*) OVER w g
    FROM retrosheet_daily
    WINDOW w AS (PARTITION BY EXTRACT(YEAR FROM game_dt), player_id
            ORDER BY game_dt, game_ct ROWS BETWEEN 59 PRECEDING AND CURRENT ROW)
), t2 AS (
    SELECT *,
           ROUND(h/ab::numeric, 3) avg,
           row_number() over (PARTITION BY player_id, year ORDER BY h/ab::numeric DESC) season_rank
    FROM t
    WHERE g = 60
    AND pa >= 186 -- Min 3.1 PA/G
    ORDER BY h/ab::numeric DESC
    )
SELECT *
FROM t2
WHERE season_rank = 1
ORDER BY avg desc LIMIT 500
