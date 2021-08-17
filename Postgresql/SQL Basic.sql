--- All the companies whose names start with 'C'.
SELECT name FROM accounts
WHERE name LIKE 'C%'

--- All companies whose names contain the string 'one' somewhere in the name.
SELECT name FROM accounts
WHERE name LIKE '%one%'

--- All companies whose names end with 's'.
SELECT name
FROM accounts
WHERE name LIKE '%s';

--- IN
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');


--- lesson 2 - Join

---Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region.
---Your final table should include three columns: the region name, the sales rep name, and the account name.
---Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name sales_rep, a.name account
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id
JOIN accounts as a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name

---Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the
---sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: the region name,
---the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name sales_rep, a.name account
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id
JOIN accounts as a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name

--- last name start with k use lIKE '% K%'
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM orders o
JOIN accounts a
ON o.account_id =a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id
WHERE o.standard_qty > 100

SELECT a.name account, w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
WHERE a.account_id = '1001'

--- lesson 3 aggregration
--- need join mutliple table to get the data we want, here we join 4 table
SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;


-- CASE  WHEN THEN ELSE END AS
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

--- Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’
--- depending on if the order is $3000 or more, or smaller than $3000.
SELECT account_id,  total_amt_usd,
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS Order_Level
FROM orders


---
select CASE WHEN total < 1000 THEN 'Less than 1000'
WHEN total >= 1000 AND total < 2000  THEN 'Between 1000 and 2000'
ELSE 'At Least 2000' END AS categories,
COUNT(*)
FROM orders
GROUP BY 1
