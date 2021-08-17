-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
-- 1. find the sales_rep in each region with sales amount
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- 2. find the max sales in each region
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;
-- Essentially, this is a JOIN of these two tables, where the region and amount match.
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM (SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1,2
        ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;


----------- WITH CTE ---------------------------------------------------------------------------
WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
  FROM sales_reps s
  JOIN accounts a
  ON a.sales_rep_id = s.id
  JOIN orders o
  ON o.account_id = a.id
  JOIN region r
  ON r.id = s.region_id
  GROUP BY 1,2
  ORDER BY 3 DESC),
t2 AS (SELECT region_name, MAX(total_amt) total_amt
         FROM t1
         GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- Q2 For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
-- 1. find total_amt_usd sales of  each region

SELECT  r.name region_name, SUM(o.total_amt_usd) total_amt,
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1

-- 2. find the region with largest sale
SELECT  MAX(total_amt) total_amt
      FROM (SELECT  r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY 1) t1


--- HAVING allow aggreate function
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) t1);
----------- WITH CTE ---------------------------------------------------------------------------
WITH t1 AS (SELECT  r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1),
t2 AS (SELECT  MAX(total_amt) total_amt
      FROM t1)

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2) -- paid attetion CTE VS subsequery difference on this selection


----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

-- Q3 How many accounts had more total purchases than the account name which has bought
-- the most standard_qty paper throughout their lifetime as a customer?
SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;
----------- WITH CTE ---------------------------------------------------------------------------
WITH t1 as (SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1),
t2 as (SELECT a.name
          FROM orders o
          JOIN accounts a
          ON a.id = o.account_id
          GROUP BY 1
          HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*) FROM t2;

----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

-- Q4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
-- 1. find the customer that spend most total_amt_usd
SELECT a.id, a.name, SUM(o.total_amt_usd) Total
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1

-- Now, we want to look at the number of events on each channel this company had, which we can match with just the id.
SELECT a.name , w.channel channel , count(*) num_events
FROM web_events w
JOIN accounts a
ON w.account_id = a.id and a.id = (SELECT id FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) Total
                                                    FROM web_events w
                                                    JOIN accounts a
                                                    ON w.account_id = a.id
                                                    JOIN orders o
                                                    ON a.id = o.account_id
                                                    GROUP BY a.id, a.name,
                                                    ORDER BY 3 DESC
                                                    LIMIT 1) t1 )
GROUP BY 1, 2
ORDER BY 3 DESC;
----------- WITH CTE -----------------------------------------------------------------------------

 WITH t1 AS(SELECT a.id, a.name, SUM(o.total_amt_usd) Total
              FROM web_events w
              JOIN accounts a
              ON w.account_id = a.id
                JOIN orders o
                ON a.id = o.account_id
                GROUP BY a.id, a.name
                ORDER BY 3 DESC
                LIMIT 1)

SELECT a.name , w.channel channel , count(*) num_events
FROM web_events w
JOIN accounts a
ON w.account_id = a.id and a.id = (SELECT id FROM t1 )
GROUP BY 1, 2
ORDER BY 3 DESC;

----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- Q5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-- find top 10 spending accounts in term of total_amt_usd
SELECT a.name, SUM(o.total_amt_usd) total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- find average amt in top 10 spending
SELECT AVG(total) Average_Spend
FROM (SELECT a.name, SUM(o.total_amt_usd) total
        FROM accounts a
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10) t1

---------- WITH CTE -----------------------------------------------------------------------------
WITH t1 AS(SELECT a.name, SUM(o.total_amt_usd) total
            FROM accounts a
            JOIN orders o
            ON a.id = o.account_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10)
SELECT AVG(total) Average_Spend
FROM t1

----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- What is the lifetime average amount spent in terms of total_amt_usd,
-- including only the companies that spent more per order, on average, than the average of all orders.

-- calculate avrage total orders
SELECT AVG(o.total_amt_usd) total_avg
FROM orders o

SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) total_avg
                  FROM orders o);

SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;

---------- WITH CTE -----------------------------------------------------------------------------
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;
