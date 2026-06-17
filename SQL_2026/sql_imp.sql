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
create trigger after_order_insert
after insert on orders
for each row
begin
    insert into order_logs(order_id,action_time)
    values (new.order_id,now());
end

insert into orders values 
(6,105,'2025-01-05','Phone','Electronics',65000,2,'Delivered','East');

SELECT * from order_logs;

-- note coalesce Returns first non-null value.

select order_id,COALESCE(status,'Unknown') as order_status
from orders;

--note partition: Splitting huge table into smaller physical chunks.NOT same as window partitioning.

create table orders_partitioned (
    order_id int,
    order_date date,
    amount decimal(10,2)
)
partition by range (year(order_date))(
    partition p2024 values less than (2025),
    partition p2025 values less than (2026)
);

select * from orders_partitioned

-- Note : DML, DCL, DCL and TCL

-- Note : 1️⃣ DDL (Data Definition Language) DDL is used to create, modify, and delete database structures.Think:Table structure, schema, indexes, constraints CREATE,ALTER,DROP,TRUNCATE,RENAME

create table employees (
    emp_id int primary key,
    emp_name varchar(100),
    salary decimal(10,2)
);

alter table employees
add department varchar(40);

desc employees;

alter table employees 
modify salary decimal(12,2);

drop table employees;       

-- NOTE : 2️⃣ DML (Data Manipulation Language)DML works with the actual data inside tables.Think:Insert, update, delete, retrieve data

insert into employees 
values (1,'sarang',50000);

select * from employees;

update employees SET salary = 60000 where emp_id = 1;

delete from employees where emp_id = 1;

--NOTE 3️⃣ DCL (Data Control Language)

--NOTE Controls who can access what.

--NOTE Used mostly by:

--NOTE DBAs
--NOTE Database administrators
--NOTE Security teams

grant select on employees to analyst_user;

grant select,insert on employees to analyst_user;

revoke insert on employees from analyst_user;


--NOTE 4️⃣ TCL (Transaction Control Language)

-- Very important for Data Engineering and Backend interviews.

-- Controls transactions.

start transaction;

update accounts SET balance=balance-1000 where id = 1;

savepoint sp1;

update accounts set balance = balance+1000 where id = 2;

rollback to sp1;

commit;