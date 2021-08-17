-- LEFT, RIGHT, LENGTH
-- Lesson 5.3 Quiz
SELECT DISTINCT RIGHT(website, 3) as DOMAIN, count(*) Total
from accounts
GROUP BY 1

SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number
-- and a second group of those company names that start with a letter. What proportion of company names start with a letter?
SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                      THEN 1 ELSE 0 END AS num,
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                      THEN 0 ELSE 1 END AS letter
FROM accounts

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                      THEN 1 ELSE 0 END AS num,
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                      THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;


-- company name with aeiou, make the name upper
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                        THEN 1 ELSE 0 END AS vowels,
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;


-- POSITION, STRPOS both case sensitive, use LOWER or UPPER
-- index of the first position is 1 in SQL
-- POSITION(',' IN city_state), STRPOS(city_state, ',')
