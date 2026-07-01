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

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    brand VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL
);

desc products;

create table orders(
    order_id int primary key auto_increment,
    user_id int,
    order_date timestamp default current_timestamp,
    total_amount decimal(10,2) not null,
    status enum ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') default 'Pending',
    shipping_address varchar(255),
    shipping_city varchar(50),
    shipping_state varchar(50),
    shipping_postal_code varchar(10),
    payment_method varchar(50),
    notes text,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (user_id) references users(user_id) on delete cascade
);

desc orders;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
    UNIQUE (order_id, product_id)
);

desc order_items;

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(100),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    UNIQUE (product_id, user_id)
);

desc reviews;

-- NOTE:Phase 5 Create Indexes
-- step 16 COMMENT
-- categories table 

create index idx_category_created_at
on categories(created_at);

--users table 
--unique and foreign key constraints are already indexed by default, so we will create indexes for frequently queried columns 
create index idx_users_created_at 
on users(created_at);

-- products table
-- category index
create index idx_products_category_id
on products(category_id);

--product_name index
create index idx_products_name
on products(product_name);

--price index
create index idx_products_price
on products(price);

--created at index 
create index idx_products_created_at
on products(created_at);

--orders table COMMENt
--user_id index COMMENT
create index idx_orders_user_id
on orders(user_id);

-- order_date index
create index idx_orders_order_date
on orders(order_date); 

--status index
create index idx_orders_status
on orders(status);

-- review table
-- products review
create index idx_reviews_product_id
on reviews(product_id);

--user reviews
create index idx_reviews_user_id
on reviews(user_id);

--rating index
create index idx_reviews_rating
on reviews(rating);

--created at index
create index idx_reviews_created_at
on reviews(created_at);

--show all indexes
SHOW INDEX FROM categories;
SHOW INDEX FROM users;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
SHOW INDEX FROM reviews;

--inseting data into tables in a specific order to avoid foreign key constraint errors

desc categories;

show columns from categories;
--sample categories
-- Electronics
-- Mobile Accessories
-- Computers & Laptops
-- Clothing & Fashion
-- Footwear
-- Home & Kitchen
-- Books
-- Sports & Fitness
-- Health & Beauty
-- Toys & Games
-- Automotive
-- Groceries
INSERT INTO categories (category_name, description)
VALUES
('Electronics', 'Electronic gadgets, devices, and accessories.'),
('Mobile Accessories', 'Accessories for smartphones and mobile devices.'),
('Computers & Laptops', 'Desktop computers, laptops, and related accessories.'),
('Clothing & Fashion', 'Men, women, and kids clothing along with fashion accessories.'),
('Footwear', 'Shoes, sandals, boots, and other footwear for all ages.'),
('Home & Kitchen', 'Home essentials, kitchen appliances, cookware, and decor.'),
('Books', 'Books across various genres, educational materials, and novels.'),
('Sports & Fitness', 'Sports equipment, fitness gear, and exercise accessories.'),
('Health & Beauty', 'Healthcare products, personal care, cosmetics, and beauty items.'),
('Toys & Games', 'Toys, board games, puzzles, and entertainment products for all ages.'),
('Automotive', 'Automobile accessories, tools, spare parts, and vehicle care products.'),
('Groceries', 'Daily grocery items, food products, beverages, and household essentials.');

select * from categories;

desc users;