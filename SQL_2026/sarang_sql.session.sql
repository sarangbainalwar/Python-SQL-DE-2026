create DATABASE IF NOT EXISTS e_commerce_project_db_2026;

USE e_commerce_project_db_2026;

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(255) not null unique,
    description text,
    created_at timestamp default current_timestamp
)

desc categories;

create table users (
    user_id int primary key auto_increment,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    email varchar(50) not null unique,
    password varchar(50) not null,
    phone varchar(20),
    address varchar(50),
    city varchar(50),
    state varchar(50), 
    postal_code varchar(20),
    country varchar(50) default 'India',
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp
)

desc users;