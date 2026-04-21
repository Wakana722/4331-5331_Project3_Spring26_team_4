-- ============================================================
-- CSE 4331/5331 Spring 2026 - Project 3
-- Task 2: SQL Query on IMDb Oracle Database (omega)
-- ============================================================

SET ECHO ON
SPOOL 4331-5331_Proj3Spring26_team_team4_output.txt

-- ENGLISH DESCRIPTION:
-- For the period [2001-2010] and genre combination Comedy + Romance:
-- Find the TOP 5 movies that:
--   1. Were released between 2001 and 2010 (inclusive)
--   2. Contain BOTH 'Comedy' AND 'Romance' in their genre list
--   3. Have received at least 150,000 votes
-- Output movie name, rating, votes, and lead actor/actress (ordering=1)
-- Ordered by rating descending, votes descending as tiebreaker

SELECT *
FROM (
    SELECT
        tb.PRIMARYTITLE         AS movie_name,
        tb.STARTYEAR            AS release_year,
        tr.AVERAGERATING        AS imdb_rating,
        tr.NUMVOTES             AS num_votes,
        nb.PRIMARYNAME          AS lead_actor_actress
    FROM
        imdb00.TITLE_BASICS     tb
        JOIN imdb00.TITLE_RATINGS tr
            ON tb.TCONST = tr.TCONST
        LEFT JOIN imdb00.TITLE_PRINCIPALS tp
            ON tb.TCONST = tp.TCONST
            AND tp.ORDERING = '1'
            AND tp.CATEGORY IN ('actor', 'actress')
        LEFT JOIN imdb00.NAME_BASICS nb
            ON tp.NCONST = nb.NCONST
    WHERE
        tb.TITLETYPE = 'movie'
        AND tb.STARTYEAR BETWEEN '2001' AND '2010'
        AND tb.GENRES LIKE '%Comedy%'
        AND tb.GENRES LIKE '%Romance%'
        AND tb.GENRES NOT LIKE '\N'
        AND tr.NUMVOTES >= 150000
    ORDER BY
        tr.AVERAGERATING DESC,
        tr.NUMVOTES      DESC
)
WHERE ROWNUM <= 5;

EXPLAIN PLAN FOR
SELECT *
FROM (
    SELECT
        tb.PRIMARYTITLE         AS movie_name,
        tb.STARTYEAR            AS release_year,
        tr.AVERAGERATING        AS imdb_rating,
        tr.NUMVOTES             AS num_votes,
        nb.PRIMARYNAME          AS lead_actor_actress
    FROM
        imdb00.TITLE_BASICS     tb
        JOIN imdb00.TITLE_RATINGS tr
            ON tb.TCONST = tr.TCONST
        LEFT JOIN imdb00.TITLE_PRINCIPALS tp
            ON tb.TCONST = tp.TCONST
            AND tp.ORDERING = '1'
            AND tp.CATEGORY IN ('actor', 'actress')
        LEFT JOIN imdb00.NAME_BASICS nb
            ON tp.NCONST = nb.NCONST
    WHERE
        tb.TITLETYPE = 'movie'
        AND tb.STARTYEAR BETWEEN '2001' AND '2010'
        AND tb.GENRES LIKE '%Comedy%'
        AND tb.GENRES LIKE '%Romance%'
        AND tb.GENRES NOT LIKE '\N'
        AND tr.NUMVOTES >= 150000
    ORDER BY
        tr.AVERAGERATING DESC,
        tr.NUMVOTES      DESC
)
WHERE ROWNUM <= 5;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SPOOL OFF
