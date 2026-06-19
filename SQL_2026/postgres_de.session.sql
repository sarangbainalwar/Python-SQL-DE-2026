select table_name from information_schema.tables
where table_schema = 'public'

create table employees(
    employee_id int primary key,
    name varchar(50),
    department varchar(30),
    salary numeric
);

insert into employees values
(1,'Rahul','IT',60000),
(2,'Priya','HR',55000),
(3,'Amit','Finance',70000),
(4,'Sneha','IT',80000);

select * from employees_mini_pj;

select * from employees_cleaned;