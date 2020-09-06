WITH year_sum AS (
    SELECT b.player_id,
           b.year_id,
           MIN(b.year_id - p.birth_year) as age,
           SUM(b.g)                    games
    FROM baseballdatabank_batting b
             JOIN baseballdatabank_people p on b.player_id = p.player_id
    GROUP BY 1, 2
)
SELECT player_id, COUNT(*) seasons
FROM year_sum
WHERE player_id NOT IN (SELECT player_id FROM baseballdatabank_pitching WHERE g > 5)
GROUP BY 1
HAVING MIN(age) >= 28
AND aVG(games) <= 50
ORDER BY seasons DESC;
