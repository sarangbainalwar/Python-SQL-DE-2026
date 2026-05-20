INSERT INTO employee_sales VALUES
(1,'Amit','Electronics',5000,'2025-01-01'),
(2,'Sarang','Electronics',7000,'2025-01-02'),
(3,'Rahul','Furniture',4000,'2025-01-01'),
(4,'Priya','Furniture',6000,'2025-01-03'),
(5,'Neha','Electronics',3000,'2025-01-04');

desc employee_sales;

-- NOTE FUNCTION_NAME() OVER (
    --PARTITION BY column
    --ORDER BY column
--)

-- note ROW_NUMBER()

select emp_name,department,sales,ROW_NUMBER() over(PARTITION BY DEpartment order by sales desc) as row_num from employee_sales;

-- note sum() over()

select emp_name,sales,sum(sales) over (order by sale_date) as running_total from employee_sales;


select emp_name,sales,avg(sales) over (partition by department) as avg_dept_sales from employee_sales;

-- note lag() and lead(): access previous row and next row
select emp_name,sales,lag(sales) over (
    order by sale_date
) as prev_sales,lead(sales) over (
    order by sale_date
) as next_row from employee_sales;

--note first_value()
select emp_name,sales,first_value(sales) over (PARTITION BY department order by sales desc) as top_sales from employee_sales;

--note last_value()
select emp_name,sales,LAST_VALUE(sales) over(order by sales rows between unbounded PRECEDING and UNBOUNDED FOLLOWING) as last_sales
from employee_sales;

--note ntile()

select emp_name,sales,ntile(3) over(order by sales desc) as bucket
from employee_sales;

--note percent_rank() Relative ranking percentage. rows whose value is below present row

select emp_name,sales,percent_rank() over(order by sales)*100 as perc_rank from employee_sales

--note cume_dist()
select emp_name,sales,cume_dist() over(order by sales)*100 as cumulative_distribution from employee_sales;

--note Nth_value()
