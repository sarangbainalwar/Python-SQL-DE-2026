create table customrs (
    customer_id int primary key,
    customer_name varchar(100),
    city varchar(50)
);

desc customrs;

alter TABLE customrs
rename to customers;

desc customers;

create table orders (
    order_id int primary key,
    customer_id int,
    order_date date,
    product varchar(100),
    category varchar(50),
    amount decimal(10,2),
    quantity int,
    status varchar(20),
    region varchar(50)
);

insert into orders values 
(1,101,'2025-01-01','Laptop','Electronics',80000,1,'Delivered','West'),
(2,102,'2025-01-02','Mouse','Electronics',1000,2,'Delivered','South'),
(3,101,'2025-01-03','Chair','Furniture',5000,1,NULL,'West'),
(4,103,'2025-01-04','Desk','Furniture',12000,1,'Pending','North'),
(5,104,'2025-01-05','Phone','Electronics',60000,1,'Delivered','East');

select * from orders;

-----MYSQL PIVOT TABLE ----
--BUG Revenue by region
select category, sum(case when region ='West' then amount else 0 end) as west,
sum(case when region ='South' then amount else 0 end) as south,
sum(case when region ='North' then amount else 0 end) as north,
sum(case when region ='East' then amount else 0 end) as east
from orders
group by category;

/* NOTE procedure to get total sales by region */

CREATE PROCEDURE GetRegionSales(IN p_reg VARCHAR(50))
BEGIN
    SELECT region, SUM(amount) AS total_sales
    FROM orders
    WHERE region = p_reg
    GROUP BY region;
END;

CALL GetRegionSales('West');

-- NOTE INDEXING
create index idx_customer
on orders(customer_id);


--- NOTE VIEW
create view delivered_orders as 
select * from orders where status = 'Delivered';

SELECT * from delivered_orders;

-- NOTE 5️⃣ FUNCTIONS 🧠 What It Is Reusable logic that RETURNS value.Difference:  Procedure may not return Function MUST return

create function tax(amount decimal(10,2))
returns decimal(10,2)
deterministic
return amount*0.18;

select tax(1000) as tax_amount;

--- NOTE Trigger
-- NOTE Audit table
create table order_logs (
    log_id int auto_increment primary key,
    order_id int,
    action_time timestamp
);

--- note mysql trigger
create trigger after_order