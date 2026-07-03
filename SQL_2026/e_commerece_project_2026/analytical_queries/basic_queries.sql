USE e_commerce_project_db_2026;

-- BASIC QUERIES (1-5):
-- Query 1: Find All Products
-- Show all products with their names, prices, and stock quantities
-- Order by price descending

desc products;
select product_name,price,stock_quantity
from products 
order by price desc;

-- Query 2: Find Products in Specific Category
-- Get all products in "Electronics" category
-- Show product name, price, stock

desc products;
desc categories;

select product_name,price,stock_quantity
from products 
where product_id = (select product_id from categories where category_name = 'Electronics')

-- Query 3: Find All Orders by Specific User
-- For user with email "rahul.sharma@email.com"
-- Show order_id, order_date, total_amount, status

select * from orders
where user_id = (select user_id from users where email='rahul.sharma@email.com')

-- Query 4: Find All Reviews for a Specific Product
-- For product "Laptop"
-- Show reviewer name, rating, comment, date

select * from reviews
where product_id in (select product_id from categories where category_name = 'Computers & Laptops')

-- Query 5: Find Out-of-Stock Products
-- Products where stock_quantity = 0
-- Show product name and category

select p.product_name,c.category_name
from products p
join categories c
on p.category_id=c.category_id
and p.stock_quantity = 0;