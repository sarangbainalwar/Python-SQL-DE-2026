-- AGGREGATE QUERIES (6-10):
-- Query 6: Count Total Products per Category
-- Group by category
-- Show category name and count of products
-- Order by count descending

select c.category_name,count(p.product_id) as total_products
from products p
join categories c
on p.category_id=c.category_id
group by c.category_id
order by total_products desc;

-- Query 7: Calculate Total Revenue
-- Sum of all order total_amounts
-- Where status = 'Delivered'

select sum(total_amount) from orders
where status='Delivered'

-- Query 8: Calculate Average Order Value
-- Average of order total_amounts
-- For orders in last 60 days

select avg(total_amount) from orders
where order_date >= curdate() - interval 2 month;

-- Query 9: Find Top 5 Most Expensive Products
-- Order by price descending
-- Show only top 5

select product_name,price
from products
order by price desc
limit 5;

-- Query 10: Count Orders by Status
-- Group by status
-- Show status and count
-- Shows how many pending, shipped, delivered, etc.

select status,count(*) as order_status
from orders
group by status;