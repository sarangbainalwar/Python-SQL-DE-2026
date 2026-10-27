create DATABASE if not exists claude_2026;

use claude_2026;

-- =====================================================================
-- sql_practice_seed.sql  |  MySQL 8.0+  |  Safe to re-run any number of times
-- =====================================================================
-- Run it:   mysql -u <user> -p < sql_practice_seed.sql
--     or:   open it in MySQL Workbench / DBeaver and run the whole script.
--
-- WHY re-runnable: every table is DROPped then rebuilt, so a half-broken
-- practice session (an accidental DELETE, say) is fixed by running this
-- file again. Re-runnable scripts are also the first lesson of idempotent
-- pipelines, which you meet in Week 2.
--
-- Tables:
--   customers        15 customers (4 have never ordered, 1 has NULL city)
--   orders           48 raw rows = 43 distinct orders + deliberate mess
--   dim_customer     SCD Type 2 history of customer city
--   stg_orders_batch tomorrow's incoming batch (Day 9 incremental load)
--   etl_watermark    last successfully loaded date (Day 9)
--   orders_big       100,000 rows, NO index on customer_id (Day 10 EXPLAIN)
-- =====================================================================

DROP TABLE IF EXISTS orders_big;
DROP TABLE IF EXISTS etl_watermark;
DROP TABLE IF EXISTS stg_orders_batch;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;


-- ---------------------------------------------------------------------
-- 1. customers
-- ---------------------------------------------------------------------
-- city holds the CURRENT city. Customers 1, 2 and 3 have moved, and their
-- full history lives in dim_customer below.
-- Customer 14 has a NULL city on purpose: GROUP BY, joins and
-- COUNT(city) vs COUNT(*) all behave differently around NULLs.
CREATE TABLE customers (
    customer_id  INT          PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL,
    city         VARCHAR(30)  NULL,
    signup_date  DATE         NOT NULL
);

INSERT INTO customers (customer_id, name, city, signup_date) VALUES
( 1, 'Aarav Sharma',   'Pune',       '2024-01-10'),  -- moved Nagpur -> Pune
( 2, 'Priya Deshmukh', 'Hyderabad',  '2024-01-25'),  -- moved twice
( 3, 'Rohan Patil',    'Mumbai',     '2024-02-14'),  -- moved Pune -> Mumbai
( 4, 'Sneha Iyer',     'Bengaluru',  '2024-03-02'),
( 5, 'Vikram Rao',     'Hyderabad',  '2024-03-18'),
( 6, 'Ananya Joshi',   'Nagpur',     '2024-04-05'),
( 7, 'Karan Mehta',    'Mumbai',     '2024-04-22'),
( 8, 'Neha Kulkarni',  'Pune',       '2024-05-09'),
( 9, 'Arjun Nair',     'Bengaluru',  '2024-06-01'),
(10, 'Divya Reddy',    'Hyderabad',  '2024-06-20'),
(11, 'Manish Gupta',   'Nagpur',     '2024-07-11'),
(12, 'Pooja Singh',    'Mumbai',     '2024-08-03'),  -- never ordered
(13, 'Rahul Verma',    'Pune',       '2024-09-15'),  -- never ordered
(14, 'Ishita Bansal',  NULL,         '2024-10-01'),  -- never ordered, NULL city
(15, 'Sameer Khan',    'Nagpur',     '2024-11-12');  -- never ordered


-- ---------------------------------------------------------------------
-- 2. orders  (a raw "landing" table, like what an upstream system sends)
-- ---------------------------------------------------------------------
-- WHY row_id is the primary key and NOT order_id: raw landing tables do
-- not enforce business uniqueness. That is exactly why duplicates exist
-- and why deduplication is a real task, not a hypothetical one.
-- WHY there is no foreign key on customer_id: real feeds contain orphans
-- (order 1042 points to customer 99, who does not exist).
CREATE TABLE orders (
    row_id       INT            AUTO_INCREMENT PRIMARY KEY,
    order_id     INT            NOT NULL,
    customer_id  INT            NULL,
    order_date   DATE           NOT NULL,
    amount       DECIMAL(12,2)  NULL,
    status       VARCHAR(20)    NOT NULL   -- 'completed', 'cancelled', 'refunded'
);

-- Batch 1: the 40 clean, distinct orders (Jan to Jun 2025).
-- Note the date gaps (e.g. nothing between 2025-04-19 and 2025-05-04):
-- these are the "days with no orders" you must handle in the rolling
-- average on Day 5.
INSERT INTO orders (order_id, customer_id, order_date, amount, status) VALUES
(1001,  1, '2025-01-05', 12000.00, 'completed'),
(1002,  2, '2025-01-06',  8500.00, 'completed'),
(1003,  3, '2025-01-06', 15000.00, 'completed'),
(1004,  1, '2025-01-09', 22000.00, 'completed'),
(1005,  4, '2025-01-10',  9500.00, 'completed'),
(1006,  5, '2025-01-12', 30000.00, 'cancelled'),
(1007,  6, '2025-01-15', 18000.00, 'completed'),
(1008,  2, '2025-01-18', 45000.00, 'completed'),
(1009,  7, '2025-01-20',  7000.00, 'completed'),
(1010,  3, '2025-01-22', 26000.00, 'refunded'),
(1011,  8, '2025-01-25', 14000.00, 'completed'),
(1012,  1, '2025-01-28', 19000.00, 'completed'),
(1013,  9, '2025-02-02', 11000.00, 'completed'),
(1014, 10, '2025-02-03', 33000.00, 'completed'),   -- gets re-sent later as 'refunded'
(1015,  4, '2025-02-05', 16500.00, 'completed'),
(1016,  5, '2025-02-08', 21000.00, 'completed'),
(1017, 11, '2025-02-10',  9000.00, 'cancelled'),
(1018,  6, '2025-02-14', 27000.00, 'completed'),
(1019,  7, '2025-02-14', 13000.00, 'completed'),   -- two orders on one day
(1020,  2, '2025-02-20', 38000.00, 'completed'),
(1021,  8, '2025-02-25', 17500.00, 'refunded'),
(1022,  3, '2025-03-03', 24000.00, 'completed'),
(1023,  1, '2025-03-05', 31000.00, 'completed'),
(1024,  9, '2025-03-09',  8000.00, 'completed'),
(1025, 10, '2025-03-12', 29000.00, 'completed'),
(1026,  5, '2025-03-18', 52000.00, 'completed'),
(1027, 11, '2025-03-21', 12500.00, 'completed'),
(1028,  4, '2025-03-27', 20000.00, 'completed'),
(1029,  6, '2025-04-02', 23000.00, 'completed'),
(1030,  7, '2025-04-08', 41000.00, 'completed'),
(1031,  2, '2025-04-15', 15500.00, 'cancelled'),
(1032,  8, '2025-04-19', 19500.00, 'completed'),
(1033,  1, '2025-05-04', 28000.00, 'completed'),
(1034,  3, '2025-05-11', 34000.00, 'completed'),
(1035, 10, '2025-05-16', 10500.00, 'completed'),
(1036,  5, '2025-05-23', 25500.00, 'completed'),
(1037,  9, '2025-06-02',  7500.00, 'completed'),
(1038, 11, '2025-06-10', 17000.00, 'completed'),
(1039,  2, '2025-06-15', 48000.00, 'completed'),
(1040,  4, '2025-06-20', 22500.00, 'completed');

-- Batch 2: the "bad data" rows. Each one is a trap for a specific skill.
INSERT INTO orders (order_id, customer_id, order_date, amount, status) VALUES
-- NULL customer_id (guest checkout). Breaks NOT IN (subquery) when this
-- column is used in the subquery; invisible to inner joins.
(1041, NULL, '2025-02-11',  6500.00, 'completed'),
-- Orphan: customer 99 does not exist. Inner join drops it, LEFT JOIN keeps it.
(1042,   99, '2025-03-14', 14000.00, 'completed'),
-- NULL amount. SUM() ignores it, AVG() ignores it, but amount > 0 is UNKNOWN.
(1043,    6, '2025-05-30',     NULL, 'completed');

-- Batch 3: a pipeline rerun re-inserted these orders. In this exercise the
-- rerun re-stamped order_date, so "latest by order_date" picks the newest copy.
INSERT INTO orders (order_id, customer_id, order_date, amount, status) VALUES
(1005,  4, '2025-01-21',  9500.00, 'completed'),   -- exact duplicate except date
(1014, 10, '2025-02-17', 33000.00, 'refunded'),    -- same order, STATUS CHANGED
(1026,  5, '2025-03-25', 52000.00, 'completed'),   -- duplicate
(1039,  2, '2025-06-18', 48000.00, 'completed'),   -- duplicate ...
(1039,  2, '2025-06-19', 48000.00, 'completed');   -- ... TRIPLICATE: deleting
                                                   -- "rank = 2" would leave 2 copies.

-- TRAP BUILT INTO THIS DATA: Bengaluru has 95,000 of completed sales once
-- deduplicated, but 104,500 if you aggregate the raw table, because the
-- duplicate of order 1005 pushes it past the Rs 1,00,000 line. Aggregating
-- before deduplicating silently gives a wrong report; that is the most
-- common real-world way pipelines produce bad numbers.


-- ---------------------------------------------------------------------
-- 3. dim_customer  (SCD Type 2)
-- ---------------------------------------------------------------------
-- Convention used here (state it in every SCD2 you ever build):
--   valid_from is INCLUSIVE, valid_to is EXCLUSIVE, and the current row
--   has valid_to = NULL. So "city on date D" is:
--     D >= valid_from AND D < COALESCE(valid_to, '9999-12-31')
-- WHY NULL for the open end: it is the common warehouse convention, and
-- it is the exact reason a plain "D < valid_to" filter silently drops
-- current rows.
CREATE TABLE dim_customer (
    customer_key  INT          AUTO_INCREMENT PRIMARY KEY,  -- surrogate key
    customer_id   INT          NOT NULL,                    -- business key
    city          VARCHAR(30)  NULL,
    valid_from    DATE         NOT NULL,
    valid_to      DATE         NULL,
    is_current    TINYINT(1)   NOT NULL
);

INSERT INTO dim_customer (customer_id, city, valid_from, valid_to, is_current) VALUES
-- Customer 1: one move
( 1, 'Nagpur',     '2024-01-10', '2025-04-01', 0),
( 1, 'Pune',       '2025-04-01', NULL,         1),
-- Customer 2: two moves (lived in Bengaluru on 2025-06-15)
( 2, 'Mumbai',     '2024-01-25', '2025-06-01', 0),
( 2, 'Bengaluru',  '2025-06-01', '2025-09-01', 0),
( 2, 'Hyderabad',  '2025-09-01', NULL,         1),
-- Customer 3: one move
( 3, 'Pune',       '2024-02-14', '2025-03-15', 0),
( 3, 'Mumbai',     '2025-03-15', NULL,         1),
-- Customers 4-15: never moved, so exactly one open row each.
( 4, 'Bengaluru',  '2024-03-02', NULL, 1),
( 5, 'Hyderabad',  '2024-03-18', NULL, 1),
( 6, 'Nagpur',     '2024-04-05', NULL, 1),
( 7, 'Mumbai',     '2024-04-22', NULL, 1),
( 8, 'Pune',       '2024-05-09', NULL, 1),
( 9, 'Bengaluru',  '2024-06-01', NULL, 1),
(10, 'Hyderabad',  '2024-06-20', NULL, 1),
(11, 'Nagpur',     '2024-07-11', NULL, 1),
(12, 'Mumbai',     '2024-08-03', NULL, 1),
(13, 'Pune',       '2024-09-15', NULL, 1),
(14, NULL,         '2024-10-01', NULL, 1),
(15, 'Nagpur',     '2024-11-12', NULL, 1);


-- ---------------------------------------------------------------------
-- 4. Day 9 material: an incoming batch and a watermark
-- ---------------------------------------------------------------------
-- Incremental loading means "only process what is new or changed since
-- the last successful run", tracked by a watermark.
CREATE TABLE etl_watermark (
    pipeline_name    VARCHAR(50)  PRIMARY KEY,
    last_loaded_date DATE         NOT NULL
);
INSERT INTO etl_watermark VALUES ('orders_daily', '2025-06-20');

-- The next batch deliberately mixes all four things a real load must handle.
-- Task on Day 9: apply it to the orders data so that reruns change nothing.
CREATE TABLE stg_orders_batch (
    order_id     INT            NOT NULL,
    customer_id  INT            NULL,
    order_date   DATE           NOT NULL,
    amount       DECIMAL(12,2)  NULL,
    status       VARCHAR(20)    NOT NULL
);
INSERT INTO stg_orders_batch VALUES
(1044,  3, '2025-06-21', 31000.00, 'completed'),  -- brand-new order
(1045,  7, '2025-06-21',  9500.00, 'completed'),  -- brand-new order
(1038, 11, '2025-06-22', 17000.00, 'refunded'),   -- existing order, status CHANGED
(1022,  3, '2025-06-22', 24000.00, 'refunded'),   -- existing order, status CHANGED
(1039,  2, '2025-06-19', 48000.00, 'completed');  -- exact rerun of a row already loaded


-- ---------------------------------------------------------------------
-- 5. Day 10 material: 100,000 rows to make EXPLAIN meaningful
-- ---------------------------------------------------------------------
-- WHY it is generated, not hardcoded: query plans on 40 rows are
-- meaningless, because the optimiser scans tiny tables regardless of
-- indexes. You need volume to see an index change the plan.
-- WHY MOD() instead of RAND(): the data is identical on every run, so
-- your EXPLAIN numbers are comparable between sessions.
-- WHY no index on customer_id yet: Day 10 is you adding it and watching
-- the plan change from a full table scan to an index lookup.
CREATE TABLE orders_big (
    order_id     INT            PRIMARY KEY,
    customer_id  INT            NOT NULL,
    order_date   DATE           NOT NULL,
    amount       DECIMAL(12,2)  NOT NULL,
    status       VARCHAR(20)    NOT NULL
);

-- MySQL caps recursive CTEs at 1000 iterations by default; raise it.
SET SESSION cte_max_recursion_depth = 100000;

INSERT INTO orders_big (order_id, customer_id, order_date, amount, status)
WITH RECURSIVE seq (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT
    n,
    MOD(n * 7919, 5000) + 1,                          -- ~5,000 customers, spread out
    DATE_ADD('2024-01-01', INTERVAL MOD(n, 365) DAY), -- one year of dates
    500 + MOD(n * 37, 50000),                         -- amounts Rs 500 to Rs 50,499
    ELT(MOD(n, 10) + 1,
        'completed','completed','completed','completed','completed',
        'completed','completed','cancelled','cancelled','refunded')  -- 70/20/10 split
FROM seq;


-- =====================================================================
-- VERIFY THE LOAD: run these and compare with the expected values.
-- =====================================================================
SELECT 'customers'        AS tbl, COUNT(*) AS row_count, 15     AS expected FROM customers
UNION ALL SELECT 'orders (raw rows)',      COUNT(*),               48     FROM orders
UNION ALL SELECT 'orders (distinct ids)',  COUNT(DISTINCT order_id), 43   FROM orders
UNION ALL SELECT 'orders NULL customer',   COUNT(*),                1     FROM orders WHERE customer_id IS NULL
UNION ALL SELECT 'orders orphan customer', COUNT(*),                1     FROM orders o
          WHERE customer_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id)
UNION ALL SELECT 'orders NULL amount',     COUNT(*),                1     FROM orders WHERE amount IS NULL
UNION ALL SELECT 'dim_customer rows',      COUNT(*),               19     FROM dim_customer
UNION ALL SELECT 'dim_customer current',   COUNT(*),               15     FROM dim_customer WHERE is_current = 1
UNION ALL SELECT 'stg_orders_batch',       COUNT(*),                5     FROM stg_orders_batch
UNION ALL SELECT 'orders_big',             COUNT(*),           100000     FROM orders_big;

-- =====================================================================
-- ANSWER KEYS FOR YOUR FIRST TEST QUERIES (do not peek before trying)
-- =====================================================================
-- Q1  Customers who never ordered       -> ids 12, 13, 14, 15
-- Q2  City completed sales > 1,00,000,
--     orders DEDUPLICATED FIRST (latest row per order_id wins):
--       Hyderabad 277500, Pune 145500, Mumbai 134000
--     (Bengaluru 95000 and Nagpur 97500 fall below the line.)
-- Q6  City on 2025-06-15                -> 15 rows; customer 1 = Pune,
--                                          customer 2 = Bengaluru, customer 3 = Mumbai
-- =====================================================================

select 100+NULL;
select concat("rs ", 100,NULL)

select * from orders;
select * from customers;

use claude_2026;

SELECT COUNT(*) FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- D2  How many rows?
SELECT * FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

select * from orders;
select * from customers;

-- How many rows?
SELECT *
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id AND o.status = 'refunded';

  select c.* from customers c
  left join orders o on o.customer_id = c.customer_id where o.order_id is null;

  select c.* from customers c where not exists(
    select 1 from orders o where o.customer_id = c.customer_id
  )


select c.* from customers c where c.customer_id not in (
    select customer_id from orders where customer_id is not null
)


A1. Customers who never ordered, written all three ways (Part 2). Confirm all three return the same rows.
A2. Customers with no order after 2025-06-01, written two ways (LEFT JOIN with the filter in ON, and NOT EXISTS). Then move the date filter into WHERE on the join version, run it, and write one sentence on why the result changed.

select c.* from customers c left join orders o on o.customer_id = c.customer_id and o.order_date > '2025-06-01'
where o.order_id is null;
select c.* from customers c left join orders o on o.customer_id = c.customer_id where o.order_date > '2025-06-01'
and o.order_id is null;


A3. Orders with no matching customer: (a) every unmatched order, (b) only the orphans (key exists but no parent), excluding NULL keys.

select o.* from orders o where o.customer_id is not null and o.customer_id not in (select customer_id from customers where customer_id is not null);

select o.* from orders o where o.customer_id is not null and not exists (select 1 from customers c where c.customer_id = o.customer_id);

A4. Run this and explain the row count in writing, then fix it so it returns only the customers who never ordered:

  SELECT c.customer_id, o.order_id, o.amount
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  WHERE o.order_id IS NULL;

  grain is 15 customer records, it fetches matching orders from orders table and filtering on amount is null, so it returns all customers who have no orders and customers who have orders with null amount.to fix it add a filter of o.order_id is null to the where clause to return only customers who never ordered. 

use claude_2026;

Part B: CASE (about 10 minutes)
B1. Count raw orders per size_band using the CASE from Part 3 (small below 10,000, medium 10,000 to 29,999, large 30,000 and above, unknown for NULL). Make sure the four counts add up to 48.
select case 
when amount < 10000 then 'small'
when amount >= 10000 and amount < 30000 then 'medium'
when amount >= 30000 then 'large'
else 'unknown' end as size_band, count(*) from orders group by size_band;

B2. Predict, then run: SELECT CASE WHEN amount is NULL THEN 'missing' ELSE 'present' END AS label, COUNT(*) FROM orders GROUP BY label;
48 present, 0 missing. Why? Because NULL is not equal to anything, even itself. Use IS NULL instead.

Part C: Conditional aggregation (about 25 minutes)
C1. Per city (join orders to customers), show total, completed, cancelled and refunded order counts in one query.

select c.city,
count(*) as total_orders,
sum(case when o.status = 'completed' then 1 else 0 end) as completed_orders,
sum(case when o.status = 'cancelled' then 1 else 0 end) as cancelled_orders,
sum(case when o.status = 'refunded' then 1 else 0 end) as refunded_orders
from orders o
join customers c on o.customer_id = c.customer_id
group by c.city;


C2. Add a refund rate per city, rounded to 2 decimals, with the divide-by-zero guard.
select c.city,
count(*) as total_orders,
sum(case when o.status = 'refunded' then 1 else 0 end) as refunded_orders,
round(
  sum(case when o.status = 'refunded' then 1 else 0 end) * 100.0 / nullif(count(*) * 1.0, 0),
  2
) as refund_rate
from orders o
join customers c on o.customer_id = c.customer_id
group by c.city;

C3. Write a one-row data-quality report on orders: total_rows, distinct_orders, dup_rows, null_customer, orphan_customer, null_amount. Hint: one LEFT JOIN to customers is enough. Before you write it, write one sentence on why that join wont change the row count (think grain and unique keys).

select count(*) as total_rows,count(distinct o.order_id) as distinct_orders,
count(*) - count(distinct o.order_id) as dup_rows,
count(case when o.customer_id is null then 1 end) as null_customer,
count(case when o.customer_id is not null and o.customer_id not in (select c.customer_id from customers c where c.customer_id is not null) then 1 end) as orphan_customer,
count(case when o.amount is null then 1 end) as null_amount
from orders o left join customers c on o.customer_id = c.customer_id;

use claude_2026;
-- GROUP BY: one row per customer, the grain changes
SELECT customer_id, COUNT(*) AS order_count
FROM orders
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

-- Window: still one row per order, the grain is unchanged
-- Why useful: you can see each order next to its customer's total, without a join back.
SELECT order_id, customer_id,
       COUNT(*) OVER (PARTITION BY customer_id) AS customer_order_count
FROM orders;

-- Compare all three on one query. Why order_date DESC: rank 1 = most recent order.
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn,
       RANK()       OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS drnk
FROM orders;


-- Day 3 - Windows functions
-- Practice (about 2 hours)

-- Use sql_practice. Run, trace in writing, log misses with a rule number.

-- Part A: Ranking functions (20 minutes)

-- A1. For customer 2 only, run the three-function query from Part 2. Explain in one sentence why rn, rnk and drnk match or differ here.

select customer_id,order_id,order_date,
row_number() over(partition by customer_id order by order_id desc) as rn,
rank() over(partition by customer_id order by order_id desc) as rnk,
dense_rank() over(partition by customer_id order by order_id desc) as drnk
from orders where customer_id = 2;
the three func differ here bcoz customer 2 has dups in order_id so each func will handle it differently, row number gives separate rank where as rank gives same rank but skips and drank doesnt skip.

-- A2. For each customer, rank their orders by amount descending using all three functions, and find a case where RANK and DENSE_RANK differ. (Hint: duplicated orders create ties.)

with cte as(select *, row_number() over(partition by customer_id order by amount desc) as rn,
rank() over(partition by customer_id order by amount desc) as rnk,
dense_rank() over(partition by customer_id order by amount desc) as drnk
from orders)

select * from cte where rnk!=drnk;

-- Part B: CTE-wrap and top-N (40 minutes)

-- B1. The most recent order per customer (exclude NULL customer_id).
with cte as (select *,row_number() over(partition by customer_id order by order_date desc, order_id asc) as rn from orders where customer_id is not null)
select * from cte where rn = 1;

-- B2. The second most recent order per customer. Customers with one order must not appear.
-- Step 1: number the copies of each order. Why partition by order_id:
-- a rerun created several rows for the same order, and rn = 1 keeps the latest copy.
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id
                              ORDER BY order_date DESC, row_id DESC) AS dedup_rn
    FROM orders
),
-- Step 2: keep one row per order. Why customer_id IS NOT NULL here:
-- a NULL-key order has no customer, so it can't be anyone's "second order".
dedup AS (
    SELECT * FROM ranked WHERE dedup_rn = 1 AND customer_id IS NOT NULL
),
-- Step 3: NOW rank each customer's orders. This is a second window, on a
-- different partition, which is why it needs its own CTE.
by_customer AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id
                              ORDER BY order_date DESC, order_id DESC) AS recency_rn
    FROM dedup
)
SELECT customer_id, order_id, order_date, amount, status
FROM by_customer
WHERE recency_rn = 2
ORDER BY customer_id;

-- B3. The top 2 orders by amount per city (join orders to customers, exclude NULL amounts), with ties included.
with cte as (select o.*,c.city,row_number() over(partition by city order by amount desc) as rn from orders o join customers c on o.customer_id = c.customer_id where o.amount is not null)
select * from cte where rn <= 2;

-- Part C: Deduplication (30 minutes)

-- C1. Return one row per order_id, keeping the latest by order_date, as a SELECT, never a DELETE. Use a deterministic tie-breaker.
with cte as (select *, row_number() over(partition by order_id order by order_date desc, amount desc) as rn from orders)
select * from cte where rn = 1;

or

with cte as (select *, row_number() over(partition by order_id order by order_date desc, status asc) as rn from orders)
select * from cte where rn = 1;


-- C2. Count completed sales per city after deduplicating, and compare with the raw count (Bengaluru should differ).
with cte as (select *, row_number() over(partition by order_id order by order_date desc, amount desc) as rn from orders),
cte2 as (select c.city, count(*) as completed_sales from customers c join cte a on c.customer_id = a.customer_id where a.rn = 1 and a.status = 'completed' group by c.city)

select c.city,c2.completed_sales,count(c.*) as raw_sales from customers c
join orders o on c.customer_id = o.customer_id
join cte2 c2 on 
group by c.city;

-- Part D: LeetCode (30 minutes). Do 185 Department Top Three Salaries and 176 Second Highest Salary.
all leetcode que done.

-- Rule 8 | Deduplicate to one row per entity BEFORE ranking, counting or summing. Grain first, then ranking.
-- B2   | second most recent per customer returned a duplicate of the latest order | ranked raw rows, not orders | Rule 8
-- B3   | ROW_NUMBER when ties were required, and duplicate rows in the top 2 | wrong function and no dedup | Rule 8
-- C2   | count(c.*), join with no ON, raw side not filtered to completed | built one tangled query instead of two same-grain summaries | Rules 6, 8

select * from orders order by customer_id,order_date desc
use claude_2026;
SELECT order_id, COUNT(*) AS copies
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

select order_id,count(*) as copies,
case when count(distinct status) > 1 or
count(distinct amount) > 1 or count(distinct customer_id) > 1 then 'content changed' else 'identical except date' end as kind 
from orders group by order_id having count(*) > 1;

--four ways to deduplcate
-- pattern A: row number
-- Why this is the default: it keeps exactly one row per key, always,
-- because ROW_NUMBER never produces ties.

with ranked as (
    select *,row_number() over(partition by order_id order by order_date desc, row_id desc) as rn from orders
)
select * from ranked where rn = 1;

--pattern B:max() plus join back (the trap)
-- Why people use it: it reads naturally ("the row with the latest date").
-- The trap: if two copies share the max date, BOTH match, so you get 2 rows for one key.
select o.* from orders o
join (select order_id,max(order_date) as last_date from orders
group by order_id) m
on m.order_id = o.order_id and m.last_date = o.order_date;

-- Pattern C: NOT EXISTS (the "no newer copy" version)

-- sql
-- Why it works: keep a row only if no newer row with the same key exists.
-- The second OR-branch is the tie-breaker; without it, tied rows would ALL survive.
use claude_2026;
select o.* from orders o 
where not exists (
    select 1 from orders n where n.order_id = o.order_id and (n.order_date > o.order_date or (n.order_date = o.order_date and n.row_id > o.row_id))
)

-- dedup is a view or derived table on top of raw  COMMENT
--why a view: raw stas untouched and everything downstream reads the clean layer. why list the columns: the clean layer should not expose helper column rn.COMMENT

create view orders_clean as 
select row_id, order_id,customer_id, order_date,amount, status from (
    select *,row_number() over(partition by order_id order by order_date desc,row_id desc) as rn
    from orders
) ranked where rn = 1;

-- run view
select * from orders_clean;

-- Why both numbers: if the key were unique, these would be equal.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM orders_clean;                         -- must show 43 and 43

-- Practice (about 2 hours)

-- Use sql_practice. For each query, run it, then write your three-answer trace.

-- Part A: Detect (20 minutes)

-- A1. List every duplicated order_id with its copy count.
select order_id,count(*) from orders group by order_id
having count(*) > 1;

-- A2. Classify each duplicated order as identical except date or content changed.
select order_id,count(*), case when count(distinct status) > 1
or count(distinct amount) > 1
or count(distinct customer_id) > 1
then 'content changed'
else 'identical except date'
end as kind from orders group by order_id having count(*) > 1;

-- Part B: Four patterns (40 minutes)

-- B1. Dedup with ROW_NUMBER. Return 43 rows.

select * from (select *,row_number() over(partition by order_id order by order_date desc,row_id desc) rn from orders) a
where rn = 1;

-- B2. Dedup with MAX plus join-back. Return 43 rows, then write one sentence on when this version would return more than one row per order.

select o.* from orders o join (select order_id,max(order_date) order_date from orders group by order_id) n on o.order_id = n.order_id and o.order_date = n.order_date; 

-- B3. Dedup with NOT EXISTS and the tie-breaker. Return 43 rows.
select o.* from orders o where not exists(
    select 1 from orders n where n.order_id = o.order_id
    and (n.order_date>o.order_date or (n.order_date=o.order_date and n.row_id>o.row_id))
)

-- B4. Prove B1, B2 and B3 return the same set of row_ids. Hint: use NOT EXISTS or NOT IN between each pair, in both directions. You expect 0 differences.
WITH B1 AS (
    SELECT row_id
    FROM (
        SELECT row_id,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id
                   ORDER BY order_date DESC, row_id ASC
               ) AS rn
        FROM orders
    ) a
    WHERE rn = 1
),
B2 AS (
    SELECT o.row_id
    FROM orders o
    JOIN (
        SELECT order_id, MAX(order_date) AS order_date
        FROM orders
        GROUP BY order_id
    ) n
      ON o.order_id = n.order_id
     AND o.order_date = n.order_date
),
B3 AS (
    SELECT o.row_id
    FROM orders o
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders n
        WHERE n.order_id = o.order_id
          AND (
              n.order_date > o.order_date
              OR (
                  n.order_date = o.order_date
                  AND n.row_id < o.row_id
              )
          )
    )
)
SELECT 'B1 minus B2' AS comparison, row_id
FROM (
    SELECT row_id FROM B1
    EXCEPT
    SELECT row_id FROM B2
) x

UNION ALL

SELECT 'B2 minus B1', row_id
FROM (
    SELECT row_id FROM B2
    EXCEPT
    SELECT row_id FROM B1
) x

UNION ALL

SELECT 'B1 minus B3', row_id
FROM (
    SELECT row_id FROM B1
    EXCEPT
    SELECT row_id FROM B3
) x

UNION ALL

SELECT 'B3 minus B1', row_id
FROM (
    SELECT row_id FROM B3
    EXCEPT
    SELECT row_id FROM B1
) x;


-- Part C: The clean layer (30 minutes)

-- C1. Create the orders_clean view from Part 5, then run the uniqueness test.
create view orders_clean as select row_id,order_id,customer_id,amount,order_date,status from(
    select *,row_number() over(partition by order_id order by order_date desc,row_id desc) as rn from orders
) ranked where rn = 1;

-- Why the same columns as raw: a clean layer should be a drop-in replacement for raw.
CREATE VIEW orders_clean AS
SELECT row_id, order_id, customer_id, order_date, amount, status
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id
                                 ORDER BY order_date DESC, row_id DESC) AS rn
    FROM orders
) ranked
WHERE rn = 1;

-- The uniqueness test, which is the assertion that proves the view is correct:
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM orders_clean;                 -- expect 43 and 43

-- C2. Count orders by status from orders_clean.
select status,count(*) from orders_clean group by status;

-- C3. List orders whose first copy’s status differs from their latest copy’s status. Show order_id, first_status, latest_status. Hint: two ranked CTEs, one ASC and one DESC, joined on order_id.
with a as(select *,row_number() over(partition by order_id order by order_date desc,row_id desc) as rn from orders),
b as(select *,row_number() over(partition by order_id order by order_date asc,row_id asc) as rn from orders)

select a.order_id,a.status,b.status from a join b
on a.order_id = b.order_id and a.status!=b.status
where a.rn=1 and b.rn=1

use claude_2026;

-- Day 5:
-- part 1: Lag and Lead


-- Days between each customer's orders, and how much the amount changed.
-- Why PARTITION BY customer_id: "previous" must mean this customer's previous order.
-- Why order_id as a second sort key: it makes the order deterministic if two
-- orders share a date (Rule 13).
use claude_2026;
select customer_id,order_id,order_date,
datediff(order_date,lag(order_date) over(partition by customer_id order by order_date,order_id)) as days_since_prev,
amount - lag(amount) over(partition by customer_id order by order_date,order_id) as amount_changed 
from orders_clean where customer_id is not null;

select order_id,prev_status,status from (select order_id,status,lag(status) over (partition by order_id order by order_date,row_id) as prev_status from orders) x
where prev_status is not null and status <> prev_status;

AVG(x) OVER (ORDER BY d ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)

select order_id,order_date,amount,sum(amount) over(order by order_date) as rt_default,sum(amount) over(order by order_date,order_id rows between unbounded preceding and current row) as tr_rows from orders_clean where status = 'completed';

--Part 3: Rolling metrics, and the sparse-dates problem

with daily as (
    select order_date,sum(amount) as daily_sales
    from orders_clean
    where status = 'completed'
    group by order_date
)select * from daily;

-- Version 1: 7 ROWS. Averages the last 7 days THAT HAVE SALES, however far back they are.
with daily as (
    select order_date,sum(amount) as daily_sales
    from orders_clean
    where status = 'completed'
    group by order_date
)
select avg(daily_sales) over(order by order_date rows between 6 preceding and current row) from daily;

-- Version 2: 7 CALENDAR DAYS (MySQL 8 syntax). Averages only the days with sales
-- inside the last 7 calendar days. Days with no row are simply not counted.
AVG(daily_sales) OVER (ORDER BY order_date RANGE BETWEEN INTERVAL 6 DAY PRECEDING AND CURRENT ROW)