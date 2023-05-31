---Note----
/*Note*/

----------------------------
----Looking at the Table----
----------------------------

select *
FROM IMDB250MoviesIMDB250Moviescsv;

--------------------------
----Change Table Name----
-------------------------

ALTER TABLE IMDB250MoviesIMDB250Moviescsv RENAME To Movies;

SELECT *
FROM Movies;

-----------------------------
----Top 5 Budgeted Movies----
-----------------------------

SELECT name, budget
from Movies
order by budget DESC
limit 5;

-----------------------
----update currency----
-----------------------

UPDATE Movies
SET
budget=REPLACE(budget,2400000000,23000000);

UPDATE Movies
SET
budget=REPLACE(budget, 550000000,6648000);

--------------------------
----Top 5 Rated Movies----
--------------------------

SELECT name, rating
from Movies
limit 10;

-----------------------------
----Top 5 Box Office Hits----
-----------------------------

SELECT name, box_office
from Movies
ORDER by box_office DESC
limit 5;

-------------------------------
----Top 5 Profitable Movies----
-------------------------------

SELECT name, budget, box_office, (box_office-budget) as 'Profit'
from Movies
order by Profit DESC;

SELECT name, budget, box_office, (box_office-budget) as 'Profit'
from Movies
order by Profit;

-----------------------------
----Most Popular Director----
-----------------------------

SELECT directors, count(*) as 'Number'
from Movies
group by directors 
order by Number desc
limit 10;

-----------------------------------
----Amount of Movies pre rating----
-----------------------------------

SELECT certificate, count(*) as 'Number'
from Movies
group by certificate
order by Number DESC;

-----------------------------
----Best years for Movies----
-----------------------------

SELECT year, count(*) as 'Number'
from Movies
group by year 
order by Number desc
limit 10;

---------------------------------------
---- Add Run Time Column in Minutes----
---------------------------------------

SELECT run_time
from Movies;

ALTER TABLE Movies
add minutes as (run_time*60);

SELECT run_time, minutes
from Movies;

--------------------------
----Most Popular Genre----
--------------------------

select genre
from Movies;

SELECT genre, COUNT(*) as genre_count
from(
  SELECT Trim(value) as genre
  from Movies
  cross join json_each('["' || REPLACE(genre, ',', '","') || '"]')
  )
  GROUP by genre
  order by genre_count DESC
  limit 10;
  
-----------------------------------  
----Amount of movies per Decade----
-----------------------------------

SELECT
  	year/10*10+1 as decade_start,
    year/10*10+10 as decade_end,
    count(year) as number
 from Movies
 group by year/10
 order by decade_start;

--------------------------------------------------
--------Most Popular Genres Per 10 Years----------
--------------------------------------------------

WITH genre_counts AS (
  SELECT genre, COUNT(*) AS genre_count, year
  FROM (
    SELECT TRIM(value) AS genre, year
    FROM Movies
    CROSS JOIN json_each('["' || REPLACE(genre, ',', '","') || '"]')
  )
  GROUP BY genre, year
), decade_max_genre AS (
  SELECT d.decade_start, d.decade_end, gc.genre,
         ROW_NUMBER() OVER (PARTITION BY d.decade_start ORDER BY gc.genre_count DESC) AS rn
  FROM (
    SELECT 
      year/10 * 10 + 1 AS decade_start,
      year/10 * 10 + 10 AS decade_end
    FROM Movies
    GROUP BY year/10
  ) d
  JOIN genre_counts gc ON gc.year >= d.decade_start AND gc.year <= d.decade_end
)
SELECT decade_start, decade_end, genre
FROM decade_max_genre
WHERE rn = 1
ORDER BY decade_start
