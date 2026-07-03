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

--inserting data into tables in a specific order to avoid foreign key constraint errors

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

INSERT INTO users
(first_name, last_name, email, password, phone, address, city, state, postal_code)
VALUES
('Rahul', 'Sharma', 'rahul.sharma@email.com', 'Rahul@123', '9876543210', '12 MG Road', 'Mumbai', 'Maharashtra', '400001'),
('Priya', 'Patel', 'priya.patel@email.com', 'Priya@123', '9876543211', '45 SG Highway', 'Ahmedabad', 'Gujarat', '380015'),
('Amit', 'Kumar', 'amit.kumar@email.com', 'Amit@123', '9876543212', '22 Civil Lines', 'Delhi', 'Delhi', '110001'),
('Sneha', 'Joshi', 'sneha.joshi@email.com', 'Sneha@123', '9876543213', '8 FC Road', 'Pune', 'Maharashtra', '411001'),
('Rohan', 'Mehta', 'rohan.mehta@email.com', 'Rohan@123', '9876543214', '56 Ring Road', 'Indore', 'Madhya Pradesh', '452001'),
('Neha', 'Singh', 'neha.singh@email.com', 'Neha@123', '9876543215', '91 Park Street', 'Kolkata', 'West Bengal', '700016'),
('Arjun', 'Verma', 'arjun.verma@email.com', 'Arjun@123', '9876543216', '18 Residency Road', 'Bengaluru', 'Karnataka', '560001'),
('Pooja', 'Gupta', 'pooja.gupta@email.com', 'Pooja@123', '9876543217', '74 Banjara Hills', 'Hyderabad', 'Telangana', '500034'),
('Vikram', 'Rao', 'vikram.rao@email.com', 'Vikram@123', '9876543218', '29 Anna Salai', 'Chennai', 'Tamil Nadu', '600002'),
('Anjali', 'Deshmukh', 'anjali.deshmukh@email.com', 'Anjali@123', '9876543219', '17 Sitabuldi', 'Nagpur', 'Maharashtra', '440001'),
('Karan', 'Shah', 'karan.shah@email.com', 'Karan@123', '9876543220', '14 Law Garden', 'Ahmedabad', 'Gujarat', '380009'),
('Meera', 'Nair', 'meera.nair@email.com', 'Meera@123', '9876543221', '11 Marine Drive', 'Kochi', 'Kerala', '682001'),
('Akash', 'Jain', 'akash.jain@email.com', 'Akash@123', '9876543222', '5 MI Road', 'Jaipur', 'Rajasthan', '302001'),
('Nisha', 'Kapoor', 'nisha.kapoor@email.com', 'Nisha@123', '9876543223', '33 Sector 17', 'Chandigarh', 'Chandigarh', '160017'),
('Siddharth', 'Kulkarni', 'siddharth.kulkarni@email.com', 'Sid@123', '9876543224', '78 Shivaji Nagar', 'Pune', 'Maharashtra', '411005'),
('Ayesha', 'Khan', 'ayesha.khan@email.com', 'Ayesha@123', '9876543225', '9 Hazratganj', 'Lucknow', 'Uttar Pradesh', '226001'),
('Ritesh', 'Yadav', 'ritesh.yadav@email.com', 'Ritesh@123', '9876543226', '67 Gomti Nagar', 'Lucknow', 'Uttar Pradesh', '226010'),
('Komal', 'Patil', 'komal.patil@email.com', 'Komal@123', '9876543227', '31 Pratap Nagar', 'Nagpur', 'Maharashtra', '440022'),
('Manish', 'Choudhary', 'manish.choudhary@email.com', 'Manish@123', '9876543228', '54 Rajwada', 'Indore', 'Madhya Pradesh', '452002'),
('Shreya', 'Iyer', 'shreya.iyer@email.com', 'Shreya@123', '9876543229', '88 T Nagar', 'Chennai', 'Tamil Nadu', '600017'),
('Deepak', 'Mishra', 'deepak.mishra@email.com', 'Deepak@123', '9876543230', '23 Alkapuri', 'Vadodara', 'Gujarat', '390007'),
('Kavita', 'Reddy', 'kavita.reddy@email.com', 'Kavita@123', '9876543231', '65 Jubilee Hills', 'Hyderabad', 'Telangana', '500033'),
('Nitin', 'Agarwal', 'nitin.agarwal@email.com', 'Nitin@123', '9876543232', '41 Nehru Place', 'Delhi', 'Delhi', '110019'),
('Divya', 'Bansal', 'divya.bansal@email.com', 'Divya@123', '9876543233', '12 Sector 62', 'Noida', 'Uttar Pradesh', '201301'),
('Harsh', 'Pandey', 'harsh.pandey@email.com', 'Harsh@123', '9876543234', '18 Civil Township', 'Bhopal', 'Madhya Pradesh', '462001'),
('Riya', 'Saxena', 'riya.saxena@email.com', 'Riya@123', '9876543235', '72 Airport Road', 'Bhopal', 'Madhya Pradesh', '462030'),
('Aditya', 'Malhotra', 'aditya.malhotra@email.com', 'Aditya@123', '9876543236', '11 Sector 22', 'Chandigarh', 'Chandigarh', '160022'),
('Simran', 'Kaur', 'simran.kaur@email.com', 'Simran@123', '9876543237', '8 Mall Road', 'Amritsar', 'Punjab', '143001'),
('Yash', 'Thakur', 'yash.thakur@email.com', 'Yash@123', '9876543238', '27 VIP Road', 'Raipur', 'Chhattisgarh', '492001'),
('Tanvi', 'Kulshreshtha', 'tanvi.k@email.com', 'Tanvi@123', '9876543239', '6 Shankar Nagar', 'Raipur', 'Chhattisgarh', '492007');

select * from users;

desc products;

INSERT INTO products
(product_name, description, category_id, price, stock_quantity, sku, brand, is_active)
VALUES
('Samsung Galaxy S25','High-quality Samsung Galaxy S25 for everyday use.',1,89999.00,5,'ELEC001','Samsung',TRUE),
('Apple iPhone 17','High-quality Apple iPhone 17 for everyday use.',1,84999.00,12,'ELEC002','Apple',TRUE),
('OnePlus 14','High-quality OnePlus 14 for everyday use.',1,49999.00,18,'ELEC003','OnePlus',TRUE),
('LG Smart TV 55','High-quality LG Smart TV 55 for everyday use.',1,64999.00,25,'ELEC004','LG',TRUE),
('Sony WH-1000XM5','High-quality Sony WH-1000XM5 for everyday use.',1,24999.00,40,'ELEC005','Sony',TRUE),
('Canon EOS 200D','High-quality Canon EOS 200D for everyday use.',1,55999.00,60,'ELEC006','Canon',TRUE),
('JBL Flip 6','High-quality JBL Flip 6 for everyday use.',1,8999.00,100,'ELEC007','JBL',TRUE),
('Noise Smart Watch','High-quality Noise Smart Watch for everyday use.',1,4999.00,150,'ELEC008','Noise',TRUE),
('Mi Power Bank 20000mAh','High-quality Mi Power Bank 20000mAh for everyday use.',1,2499.00,5,'ELEC009','Xiaomi',TRUE),
('Boat Airdopes 311','High-quality Boat Airdopes 311 for everyday use.',1,1999.00,12,'ELEC010','Boat',TRUE),
('USB-C Fast Charger','High-quality USB-C Fast Charger for everyday use.',2,999.00,18,'MOB011','Boat',TRUE),
('Tempered Glass','High-quality Tempered Glass for everyday use.',2,399.00,25,'MOB012','Spigen',TRUE),
('Wireless Charger','High-quality Wireless Charger for everyday use.',2,1999.00,40,'MOB013','Anker',TRUE),
('Phone Case','High-quality Phone Case for everyday use.',2,599.00,60,'MOB014','Ringke',TRUE),
('Bluetooth Selfie Stick','High-quality Bluetooth Selfie Stick for everyday use.',2,1299.00,100,'MOB015','Portronics',TRUE),
('Car Mobile Holder','High-quality Car Mobile Holder for everyday use.',2,799.00,150,'MOB016','Amkette',TRUE),
('USB-C Cable','High-quality USB-C Cable for everyday use.',2,499.00,5,'MOB017','Boat',TRUE),
('Lightning Cable','High-quality Lightning Cable for everyday use.',2,1299.00,12,'MOB018','Apple',TRUE),
('Screen Cleaner Kit','High-quality Screen Cleaner Kit for everyday use.',2,299.00,18,'MOB019','3M',TRUE),
('MagSafe Wallet','High-quality MagSafe Wallet for everyday use.',2,2499.00,25,'MOB020','Apple',TRUE),
('Dell Inspiron 15','High-quality Dell Inspiron 15 for everyday use.',3,58999.00,40,'COMP021','Dell',TRUE),
('HP Pavilion 14','High-quality HP Pavilion 14 for everyday use.',3,67999.00,60,'COMP022','HP',TRUE),
('Lenovo ThinkPad E14','High-quality Lenovo ThinkPad E14 for everyday use.',3,72999.00,100,'COMP023','Lenovo',TRUE),
('ASUS TUF A15','High-quality ASUS TUF A15 for everyday use.',3,84999.00,150,'COMP024','Asus',TRUE),
('MacBook Air M4','High-quality MacBook Air M4 for everyday use.',3,99999.00,5,'COMP025','Apple',TRUE),
('Mechanical Keyboard','High-quality Mechanical Keyboard for everyday use.',3,6999.00,12,'COMP026','Keychron',TRUE),
('Gaming Mouse','High-quality Gaming Mouse for everyday use.',3,2499.00,18,'COMP027','Logitech',TRUE),
('27 Inch Monitor','High-quality 27 Inch Monitor for everyday use.',3,18999.00,25,'COMP028','LG',TRUE),
('Logitech Webcam','High-quality Logitech Webcam for everyday use.',3,4999.00,40,'COMP029','Logitech',TRUE),
('Samsung 1TB SSD','High-quality Samsung 1TB SSD for everyday use.',3,7999.00,60,'COMP030','Samsung',TRUE),
('Men Cotton T-Shirt','High-quality Men Cotton T-Shirt for everyday use.',4,799.00,100,'CLTH031','Levis',TRUE),
('Women Kurti','High-quality Women Kurti for everyday use.',4,1499.00,150,'CLTH032','Biba',TRUE),
('Slim Fit Jeans','High-quality Slim Fit Jeans for everyday use.',4,1999.00,5,'CLTH033','Levis',TRUE),
('Formal Shirt','High-quality Formal Shirt for everyday use.',4,1799.00,12,'CLTH034','Peter England',TRUE),
('Leather Jacket','High-quality Leather Jacket for everyday use.',4,4999.00,18,'CLTH035','Zara',TRUE),
('Hoodie','High-quality Hoodie for everyday use.',4,2499.00,25,'CLTH036','Nike',TRUE),
('Track Pants','High-quality Track Pants for everyday use.',4,1599.00,40,'CLTH037','Puma',TRUE),
('Sweatshirt','High-quality Sweatshirt for everyday use.',4,1999.00,60,'CLTH038','Adidas',TRUE),
('Silk Saree','High-quality Silk Saree for everyday use.',4,3999.00,100,'CLTH039','Manyavar',TRUE),
('Navy Blazer','High-quality Navy Blazer for everyday use.',4,4499.00,150,'CLTH040','Raymond',TRUE),
('Nike Running Shoes','High-quality Nike Running Shoes for everyday use.',5,4999.00,5,'FOOT041','Nike',TRUE),
('Adidas Sneakers','High-quality Adidas Sneakers for everyday use.',5,5999.00,12,'FOOT042','Adidas',TRUE),
('Puma Sports Shoes','High-quality Puma Sports Shoes for everyday use.',5,4499.00,18,'FOOT043','Puma',TRUE),
('Woodland Boots','High-quality Woodland Boots for everyday use.',5,6999.00,25,'FOOT044','Woodland',TRUE),
('Crocs Sandals','High-quality Crocs Sandals for everyday use.',5,2999.00,40,'FOOT045','Crocs',TRUE),
('Mixer Grinder','High-quality Mixer Grinder for everyday use.',6,3499.00,60,'HOME046','Prestige',TRUE),
('Air Fryer','High-quality Air Fryer for everyday use.',6,8999.00,100,'HOME047','Philips',TRUE),
('Microwave Oven','High-quality Microwave Oven for everyday use.',6,14999.00,150,'HOME048','LG',TRUE),
('Pressure Cooker','High-quality Pressure Cooker for everyday use.',6,1999.00,5,'HOME049','Prestige',TRUE),
('Dinner Set','High-quality Dinner Set for everyday use.',6,2499.00,12,'HOME050','Cello',TRUE),
('Vacuum Cleaner','High-quality Vacuum Cleaner for everyday use.',6,11999.00,18,'HOME051','Eureka Forbes',TRUE),
('Water Purifier','High-quality Water Purifier for everyday use.',6,14999.00,25,'HOME052','Kent',TRUE),
('Coffee Maker','High-quality Coffee Maker for everyday use.',6,4999.00,40,'HOME053','Philips',TRUE),
('Rice Cooker','High-quality Rice Cooker for everyday use.',6,3499.00,60,'HOME054','Prestige',TRUE),
('Gas Stove','High-quality Gas Stove for everyday use.',6,5999.00,100,'HOME055','Prestige',TRUE),
('Atomic Habits','High-quality Atomic Habits for everyday use.',7,599.00,150,'BOOK056','Penguin',TRUE),
('Rich Dad Poor Dad','High-quality Rich Dad Poor Dad for everyday use.',7,499.00,5,'BOOK057','Penguin',TRUE),
('Psychology of Money','High-quality Psychology of Money for everyday use.',7,450.00,12,'BOOK058','Jaico',TRUE),
('Harry Potter','High-quality Harry Potter for everyday use.',7,799.00,18,'BOOK059','Bloomsbury',TRUE),
('Deep Work','High-quality Deep Work for everyday use.',7,699.00,25,'BOOK060','Piatkus',TRUE),
('The Alchemist','High-quality The Alchemist for everyday use.',7,399.00,40,'BOOK061','Harper',TRUE),
('Think and Grow Rich','High-quality Think and Grow Rich for everyday use.',7,350.00,60,'BOOK062','Fingerprint',TRUE),
('Clean Code','High-quality Clean Code for everyday use.',7,899.00,100,'BOOK063','Pearson',TRUE),
('Python Crash Course','High-quality Python Crash Course for everyday use.',7,999.00,150,'BOOK064','No Starch',TRUE),
('SQL Cookbook','High-quality SQL Cookbook for everyday use.',7,1099.00,5,'BOOK065','OReilly',TRUE),
('Cricket Bat','High-quality Cricket Bat for everyday use.',8,2499.00,12,'SPRT066','SG',TRUE),
('Football','High-quality Football for everyday use.',8,999.00,18,'SPRT067','Nivia',TRUE),
('Basketball','High-quality Basketball for everyday use.',8,1499.00,25,'SPRT068','Spalding',TRUE),
('Badminton Racket','High-quality Badminton Racket for everyday use.',8,2999.00,40,'SPRT069','Yonex',TRUE),
('Yoga Mat','High-quality Yoga Mat for everyday use.',8,799.00,60,'SPRT070','Boldfit',TRUE),
('Dumbbells 10kg','High-quality Dumbbells 10kg for everyday use.',8,3999.00,100,'SPRT071','Kore',TRUE),
('Resistance Bands','High-quality Resistance Bands for everyday use.',8,699.00,150,'SPRT072','Boldfit',TRUE),
('Skipping Rope','High-quality Skipping Rope for everyday use.',8,499.00,5,'SPRT073','Nivia',TRUE),
('Gym Gloves','High-quality Gym Gloves for everyday use.',8,599.00,12,'SPRT074','Nike',TRUE),
('Protein Shaker','High-quality Protein Shaker for everyday use.',8,699.00,18,'SPRT075','MuscleBlaze',TRUE),
('Face Wash','High-quality Face Wash for everyday use.',9,299.00,25,'BEAU076','Himalaya',TRUE),
('Moisturizer','High-quality Moisturizer for everyday use.',9,399.00,40,'BEAU077','Nivea',TRUE),
('Sunscreen SPF50','High-quality Sunscreen SPF50 for everyday use.',9,499.00,60,'BEAU078','Mamaearth',TRUE),
('Hair Dryer','High-quality Hair Dryer for everyday use.',9,2499.00,100,'BEAU079','Philips',TRUE),
('Hair Oil','High-quality Hair Oil for everyday use.',9,299.00,150,'BEAU080','Parachute',TRUE),
('Shampoo','High-quality Shampoo for everyday use.',9,499.00,5,'BEAU081','LOréal',TRUE),
('Perfume','High-quality Perfume for everyday use.',9,799.00,12,'BEAU082','Fogg',TRUE),
('Body Wash','High-quality Body Wash for everyday use.',9,349.00,18,'BEAU083','Nivea',TRUE),
('Lip Balm','High-quality Lip Balm for everyday use.',9,199.00,25,'BEAU084','Nivea',TRUE),
('Trimmer','High-quality Trimmer for everyday use.',9,1499.00,40,'BEAU085','Philips',TRUE),
('Lego Classic Set','High-quality Lego Classic Set for everyday use.',10,2999.00,60,'TOY086','LEGO',TRUE),
('Remote Control Car','High-quality Remote Control Car for everyday use.',10,1999.00,100,'TOY087','Hot Wheels',TRUE),
('Puzzle Cube','High-quality Puzzle Cube for everyday use.',10,399.00,150,'TOY088','QiYi',TRUE),
('Chess Board','High-quality Chess Board for everyday use.',10,899.00,5,'TOY089','StonKraft',TRUE),
('Barbie Doll','High-quality Barbie Doll for everyday use.',10,1499.00,12,'TOY090','Mattel',TRUE),
('Building Blocks','High-quality Building Blocks for everyday use.',10,999.00,18,'TOY091','Funskool',TRUE),
('Helmet','High-quality Helmet for everyday use.',11,1899.00,25,'AUTO092','Steelbird',TRUE),
('Car Vacuum Cleaner','High-quality Car Vacuum Cleaner for everyday use.',11,2499.00,40,'AUTO093','Agaro',TRUE),
('Car Cover','High-quality Car Cover for everyday use.',11,1599.00,60,'AUTO094','AutoCare',TRUE),
('Engine Oil','High-quality Engine Oil for everyday use.',11,899.00,100,'AUTO095','Castrol',TRUE),
('Tyre Inflator','High-quality Tyre Inflator for everyday use.',11,2999.00,150,'AUTO096','Michelin',TRUE),
('Bike Cover','High-quality Bike Cover for everyday use.',11,999.00,5,'AUTO097','AutoCare',TRUE),
('Phone Holder','High-quality Phone Holder for everyday use.',11,699.00,12,'AUTO098','Portronics',TRUE),
('Basmati Rice 5kg','High-quality Basmati Rice 5kg for everyday use.',12,699.00,18,'GROC099','India Gate',TRUE),
('Olive Oil 1L','High-quality Olive Oil 1L for everyday use.',12,899.00,25,'GROC100','Borges',TRUE);


INSERT INTO orders
(user_id, order_date, total_amount, status, shipping_address, shipping_city, shipping_state, shipping_postal_code, payment_method, notes)
VALUES
(1, '2025-12-08 10:00:00', 1299.00, 'Delivered', '100 Main Road', 'Mumbai', 'Maharashtra', '400001', 'UPI', 'Delivered successfully.'),
(8, '2025-12-11 09:00:00', 2749.00, 'Delivered', '101 Main Road', 'Pune', 'Maharashtra', '411001', 'Credit Card', 'Delivered successfully.'),
(15, '2025-12-14 08:00:00', 4499.00, 'Delivered', '102 Main Road', 'Nagpur', 'Maharashtra', '440001', 'Debit Card', 'Delivered successfully.'),
(22, '2025-12-17 07:00:00', 6249.00, 'Delivered', '103 Main Road', 'Delhi', 'Delhi', '110001', 'Net Banking', 'Delivered successfully.'),
(29, '2025-12-20 06:00:00', 7999.00, 'Delivered', '104 Main Road', 'Bengaluru', 'Karnataka', '560001', 'Cash on Delivery', 'Delivered successfully.'),
(6, '2025-12-23 05:00:00', 10249.00, 'Delivered', '105 Main Road', 'Hyderabad', 'Telangana', '500001', 'Wallet', 'Delivered successfully.'),
(13, '2025-12-26 04:00:00', 15499.00, 'Delivered', '106 Main Road', 'Chennai', 'Tamil Nadu', '600001', 'UPI', 'Delivered successfully.'),
(20, '2025-12-29 03:00:00', 3049.00, 'Delivered', '107 Main Road', 'Ahmedabad', 'Gujarat', '380001', 'Credit Card', 'Delivered successfully.'),
(27, '2026-01-01 10:00:00', 3199.00, 'Delivered', '108 Main Road', 'Jaipur', 'Rajasthan', '302001', 'Debit Card', 'Delivered successfully.'),
(4, '2026-01-04 09:00:00', 4849.00, 'Delivered', '109 Main Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Net Banking', 'Delivered successfully.'),
(11, '2026-01-07 08:00:00', 1099.00, 'Delivered', '110 Main Road', 'Mumbai', 'Maharashtra', '400001', 'Cash on Delivery', 'Delivered successfully.'),
(18, '2026-01-10 07:00:00', 1649.00, 'Delivered', '111 Main Road', 'Pune', 'Maharashtra', '411001', 'Wallet', 'Delivered successfully.'),
(25, '2026-01-13 06:00:00', 1799.00, 'Delivered', '112 Main Road', 'Nagpur', 'Maharashtra', '440001', 'UPI', 'Delivered successfully.'),
(2, '2026-01-16 05:00:00', 6749.00, 'Delivered', '113 Main Road', 'Delhi', 'Delhi', '110001', 'Credit Card', 'Delivered successfully.'),
(9, '2026-01-19 04:00:00', 12499.00, 'Delivered', '114 Main Road', 'Bengaluru', 'Karnataka', '560001', 'Debit Card', 'Delivered successfully.'),
(16, '2026-01-22 03:00:00', 2049.00, 'Delivered', '115 Main Road', 'Hyderabad', 'Telangana', '500001', 'Net Banking', 'Delivered successfully.'),
(23, '2026-01-25 10:00:00', 2499.00, 'Delivered', '116 Main Road', 'Chennai', 'Tamil Nadu', '600001', 'Cash on Delivery', 'Delivered successfully.'),
(30, '2026-01-28 09:00:00', 4249.00, 'Delivered', '117 Main Road', 'Ahmedabad', 'Gujarat', '380001', 'Wallet', 'Delivered successfully.'),
(7, '2026-01-31 08:00:00', 5999.00, 'Delivered', '118 Main Road', 'Jaipur', 'Rajasthan', '302001', 'UPI', 'Delivered successfully.'),
(14, '2026-02-03 07:00:00', 8749.00, 'Delivered', '119 Main Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Credit Card', 'Delivered successfully.'),
(21, '2026-02-06 06:00:00', 9999.00, 'Delivered', '120 Main Road', 'Mumbai', 'Maharashtra', '400001', 'Debit Card', 'Delivered successfully.'),
(28, '2026-02-09 05:00:00', 15249.00, 'Delivered', '121 Main Road', 'Pune', 'Maharashtra', '411001', 'Net Banking', 'Delivered successfully.'),
(5, '2026-02-12 04:00:00', 2799.00, 'Delivered', '122 Main Road', 'Nagpur', 'Maharashtra', '440001', 'Cash on Delivery', 'Delivered successfully.'),
(12, '2026-02-15 03:00:00', 3949.00, 'Delivered', '123 Main Road', 'Delhi', 'Delhi', '110001', 'Wallet', 'Delivered successfully.'),
(19, '2026-02-18 10:00:00', 4599.00, 'Delivered', '124 Main Road', 'Bengaluru', 'Karnataka', '560001', 'UPI', 'Delivered successfully.'),
(26, '2026-02-21 09:00:00', 849.00, 'Delivered', '125 Main Road', 'Hyderabad', 'Telangana', '500001', 'Credit Card', 'Delivered successfully.'),
(3, '2026-02-24 08:00:00', 1399.00, 'Delivered', '126 Main Road', 'Chennai', 'Tamil Nadu', '600001', 'Debit Card', 'Delivered successfully.'),
(10, '2026-02-27 07:00:00', 2549.00, 'Delivered', '127 Main Road', 'Ahmedabad', 'Gujarat', '380001', 'Net Banking', 'Delivered successfully.'),
(17, '2026-03-02 06:00:00', 6499.00, 'Processing', '128 Main Road', 'Jaipur', 'Rajasthan', '302001', 'Cash on Delivery', 'Preparing for shipment.'),
(24, '2026-03-05 05:00:00', 12249.00, 'Processing', '129 Main Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Wallet', 'Preparing for shipment.'),
(1, '2026-03-08 04:00:00', 1799.00, 'Processing', '130 Main Road', 'Mumbai', 'Maharashtra', '400001', 'UPI', 'Preparing for shipment.'),
(8, '2026-03-11 03:00:00', 3249.00, 'Processing', '131 Main Road', 'Pune', 'Maharashtra', '411001', 'Credit Card', 'Preparing for shipment.'),
(15, '2026-03-14 10:00:00', 3999.00, 'Processing', '132 Main Road', 'Nagpur', 'Maharashtra', '440001', 'Debit Card', 'Preparing for shipment.'),
(22, '2026-03-17 09:00:00', 5749.00, 'Processing', '133 Main Road', 'Delhi', 'Delhi', '110001', 'Net Banking', 'Preparing for shipment.'),
(29, '2026-03-20 08:00:00', 8499.00, 'Processing', '134 Main Road', 'Bengaluru', 'Karnataka', '560001', 'Cash on Delivery', 'Preparing for shipment.'),
(6, '2026-03-23 07:00:00', 10749.00, 'Processing', '135 Main Road', 'Hyderabad', 'Telangana', '500001', 'Wallet', 'Preparing for shipment.'),
(13, '2026-03-26 06:00:00', 14999.00, 'Pending', '136 Main Road', 'Chennai', 'Tamil Nadu', '600001', 'UPI', 'Awaiting payment confirmation.'),
(20, '2026-03-29 05:00:00', 2549.00, 'Pending', '137 Main Road', 'Ahmedabad', 'Gujarat', '380001', 'Credit Card', 'Awaiting payment confirmation.'),
(27, '2026-04-01 04:00:00', 3699.00, 'Pending', '138 Main Road', 'Jaipur', 'Rajasthan', '302001', 'Debit Card', 'Awaiting payment confirmation.'),
(4, '2026-04-04 03:00:00', 5349.00, 'Pending', '139 Main Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Net Banking', 'Awaiting payment confirmation.'),
(11, '2026-04-07 10:00:00', 599.00, 'Pending', '140 Main Road', 'Mumbai', 'Maharashtra', '400001', 'Cash on Delivery', 'Awaiting payment confirmation.'),
(18, '2026-04-10 09:00:00', 1149.00, 'Pending', '141 Main Road', 'Pune', 'Maharashtra', '411001', 'Wallet', 'Awaiting payment confirmation.'),
(25, '2026-04-13 08:00:00', 2299.00, 'Pending', '142 Main Road', 'Nagpur', 'Maharashtra', '440001', 'UPI', 'Awaiting payment confirmation.'),
(2, '2026-04-16 07:00:00', 7249.00, 'Pending', '143 Main Road', 'Delhi', 'Delhi', '110001', 'Credit Card', 'Awaiting payment confirmation.'),
(9, '2026-04-19 06:00:00', 11999.00, 'Shipped', '144 Main Road', 'Bengaluru', 'Karnataka', '560001', 'Debit Card', 'In transit.'),
(16, '2026-04-22 05:00:00', 1549.00, 'Shipped', '145 Main Road', 'Hyderabad', 'Telangana', '500001', 'Net Banking', 'In transit.'),
(23, '2026-04-25 04:00:00', 2999.00, 'Shipped', '146 Main Road', 'Chennai', 'Tamil Nadu', '600001', 'Cash on Delivery', 'In transit.'),
(30, '2026-04-28 03:00:00', 4749.00, 'Shipped', '147 Main Road', 'Ahmedabad', 'Gujarat', '380001', 'Wallet', 'In transit.'),
(7, '2026-05-01 10:00:00', 5499.00, 'Cancelled', '148 Main Road', 'Jaipur', 'Rajasthan', '302001', 'UPI', 'Cancelled by customer.'),
(14, '2026-05-04 09:00:00', 8249.00, 'Cancelled', '149 Main Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Credit Card', 'Cancelled by customer.');

INSERT INTO order_items
(order_id, product_id, quantity, price, subtotal)
VALUES
(1, 21, 1, 58999.00, 58999.00),
(1, 27, 2, 2499.00, 4998.00),
(1, 26, 1, 6999.00, 6999.00),
(1, 1, 1, 89999.00, 89999.00),
(2, 1, 1, 89999.00, 89999.00),
(2, 11, 1, 999.00, 999.00),
(2, 10, 1, 1999.00, 1999.00),
(2, 2, 1, 1002.00, 1002.00),
(3, 41, 1, 4999.00, 4999.00),
(3, 31, 1, 799.00, 799.00),
(3, 1, 1, 89999.00, 89999.00),
(3, 2, 1, 1002.00, 1002.00),
(4, 53, 1, 4999.00, 4999.00),
(4, 100, 1, 899.00, 899.00),
(4, 1, 1, 89999.00, 89999.00),
(4, 2, 1, 1002.00, 1002.00),
(5, 66, 1, 2499.00, 2499.00),
(5, 75, 1, 699.00, 699.00),
(5, 1, 1, 89999.00, 89999.00),
(5, 2, 2, 1002.00, 2004.00),
(6, 76, 1, 299.00, 299.00),
(6, 77, 1, 399.00, 399.00),
(6, 78, 2, 499.00, 998.00),
(6, 1, 2, 89999.00, 179998.00),
(7, 46, 1, 3499.00, 3499.00),
(7, 55, 1, 1055.00, 1055.00),
(7, 1, 1, 89999.00, 89999.00),
(7, 2, 1, 1002.00, 1002.00),
(8, 56, 1, 599.00, 599.00),
(8, 57, 1, 1057.00, 1057.00),
(8, 1, 1, 89999.00, 89999.00),
(8, 2, 1, 1002.00, 1002.00),
(9, 86, 1, 2999.00, 2999.00),
(9, 87, 1, 1999.00, 1999.00),
(9, 1, 1, 89999.00, 89999.00),
(9, 2, 1, 1002.00, 1002.00),
(10, 92, 1, 1899.00, 1899.00),
(10, 95, 2, 899.00, 1798.00),
(10, 1, 1, 89999.00, 89999.00),
(10, 2, 1, 1002.00, 1002.00),
(11, 21, 1, 58999.00, 58999.00),
(11, 27, 1, 2499.00, 2499.00),
(11, 26, 1, 6999.00, 6999.00),
(12, 1, 1, 89999.00, 89999.00),
(12, 11, 1, 999.00, 999.00),
(12, 10, 1, 1999.00, 1999.00),
(13, 41, 1, 4999.00, 4999.00),
(13, 31, 1, 799.00, 799.00),
(13, 1, 2, 89999.00, 179998.00),
(14, 53, 1, 4999.00, 4999.00),
(14, 100, 1, 899.00, 899.00),
(14, 1, 1, 89999.00, 89999.00),
(15, 66, 1, 2499.00, 2499.00),
(15, 75, 1, 699.00, 699.00),
(15, 1, 1, 89999.00, 89999.00),
(16, 76, 1, 299.00, 299.00),
(16, 77, 1, 399.00, 399.00),
(16, 78, 1, 499.00, 499.00),
(17, 46, 2, 3499.00, 6998.00),
(17, 55, 1, 1055.00, 1055.00),
(17, 1, 1, 89999.00, 89999.00),
(18, 56, 1, 599.00, 599.00),
(18, 57, 1, 1057.00, 1057.00),
(18, 1, 1, 89999.00, 89999.00),
(19, 86, 2, 2999.00, 5998.00),
(19, 87, 1, 1999.00, 1999.00),
(19, 1, 1, 89999.00, 89999.00),
(20, 92, 2, 1899.00, 3798.00),
(20, 95, 1, 899.00, 899.00),
(20, 1, 2, 89999.00, 179998.00),
(21, 21, 2, 58999.00, 117998.00),
(21, 27, 1, 2499.00, 2499.00),
(21, 26, 1, 6999.00, 6999.00),
(22, 1, 1, 89999.00, 89999.00),
(22, 11, 1, 999.00, 999.00),
(22, 10, 1, 1999.00, 1999.00),
(23, 41, 1, 4999.00, 4999.00),
(23, 31, 1, 799.00, 799.00),
(23, 1, 1, 89999.00, 89999.00),
(24, 53, 2, 4999.00, 9998.00),
(24, 100, 1, 899.00, 899.00),
(24, 1, 1, 89999.00, 89999.00),
(25, 66, 2, 2499.00, 4998.00),
(25, 75, 1, 699.00, 699.00),
(25, 1, 1, 89999.00, 89999.00),
(26, 76, 1, 299.00, 299.00),
(26, 77, 1, 399.00, 399.00),
(26, 78, 1, 499.00, 499.00),
(27, 46, 1, 3499.00, 3499.00),
(27, 55, 1, 1055.00, 1055.00),
(27, 1, 2, 89999.00, 179998.00),
(28, 56, 2, 599.00, 1198.00),
(28, 57, 1, 1057.00, 1057.00),
(28, 1, 1, 89999.00, 89999.00),
(29, 86, 1, 2999.00, 2999.00),
(29, 87, 1, 1999.00, 1999.00),
(29, 1, 1, 89999.00, 89999.00),
(30, 92, 1, 1899.00, 1899.00),
(30, 95, 1, 899.00, 899.00),
(30, 1, 1, 89999.00, 89999.00),
(31, 21, 1, 58999.00, 58999.00),
(31, 27, 1, 2499.00, 2499.00),
(31, 26, 1, 6999.00, 6999.00),
(32, 1, 1, 89999.00, 89999.00),
(32, 11, 1, 999.00, 999.00),
(32, 10, 2, 1999.00, 3998.00),
(33, 41, 1, 4999.00, 4999.00),
(33, 31, 1, 799.00, 799.00),
(33, 1, 1, 89999.00, 89999.00),
(34, 53, 1, 4999.00, 4999.00),
(34, 100, 1, 899.00, 899.00),
(34, 1, 2, 89999.00, 179998.00),
(35, 66, 1, 2499.00, 2499.00),
(35, 75, 1, 699.00, 699.00),
(35, 1, 1, 89999.00, 89999.00),
(36, 76, 2, 299.00, 598.00),
(36, 77, 1, 399.00, 399.00),
(36, 78, 1, 499.00, 499.00),
(37, 46, 1, 3499.00, 3499.00),
(37, 55, 1, 1055.00, 1055.00),
(37, 1, 1, 89999.00, 89999.00),
(38, 56, 1, 599.00, 599.00),
(38, 57, 1, 1057.00, 1057.00),
(38, 1, 1, 89999.00, 89999.00),
(39, 86, 1, 2999.00, 2999.00),
(39, 87, 2, 1999.00, 3998.00),
(39, 1, 1, 89999.00, 89999.00),
(40, 92, 1, 1899.00, 1899.00),
(40, 95, 1, 899.00, 899.00),
(40, 1, 1, 89999.00, 89999.00),
(41, 21, 1, 58999.00, 58999.00),
(41, 27, 1, 2499.00, 2499.00),
(42, 1, 1, 89999.00, 89999.00),
(42, 11, 1, 999.00, 999.00),
(43, 41, 2, 4999.00, 9998.00),
(43, 31, 1, 799.00, 799.00),
(44, 53, 1, 4999.00, 4999.00),
(44, 100, 1, 899.00, 899.00),
(45, 66, 1, 2499.00, 2499.00),
(45, 75, 1, 699.00, 699.00),
(46, 76, 1, 299.00, 299.00),
(46, 77, 1, 399.00, 399.00),
(47, 46, 1, 3499.00, 3499.00),
(47, 55, 1, 1055.00, 1055.00),
(48, 56, 1, 599.00, 599.00),
(48, 57, 2, 1057.00, 2114.00),
(49, 86, 1, 2999.00, 2999.00),
(49, 87, 1, 1999.00, 1999.00),
(50, 92, 1, 1899.00, 1899.00),
(50, 95, 1, 899.00, 899.00);


INSERT INTO reviews
(product_id, user_id, rating, title, comment, is_verified_purchase, helpful_count)
VALUES
(1, 1, 5, 'Excellent Product', 'Would definitely buy again.', TRUE, 8),
(8, 2, 5, 'Excellent Product', 'Excellent quality and performance.', TRUE, 60),
(15, 3, 1, 'Not Recommended', 'Would not recommend.', TRUE, 93),
(22, 4, 3, 'Good Overall', 'Average product.', TRUE, 82),
(29, 5, 3, 'Good Overall', 'Nothing exceptional but usable.', TRUE, 91),
(36, 6, 3, 'Average Quality', 'Average product.', TRUE, 44),
(43, 7, 5, 'Highly Recommended', 'Excellent quality and performance.', TRUE, 45),
(50, 8, 2, 'Could Be Better', 'Expected better quality.', TRUE, 63),
(57, 9, 3, 'Meets Expectations', 'It''s okay for the price.', TRUE, 98),
(64, 10, 5, 'Highly Recommended', 'Fantastic product for the price.', TRUE, 94),
(71, 11, 5, 'Amazing Quality', 'Excellent quality and performance.', TRUE, 50),
(78, 12, 5, 'Amazing Quality', 'Fantastic product for the price.', TRUE, 21),
(85, 13, 4, 'Good Packaging', 'Works well and is worth buying.', TRUE, 70),
(92, 14, 3, 'Good Overall', 'Nothing exceptional but usable.', TRUE, 104),
(99, 15, 5, 'Amazing Quality', 'Would definitely buy again.', TRUE, 35),
(6, 16, 4, 'Fast Delivery', 'Works well and is worth buying.', TRUE, 87),
(13, 17, 5, 'Excellent Product', 'Exceeded my expectations.', TRUE, 19),
(20, 18, 4, 'Nice Design', 'Good quality with minor issues.', TRUE, 19),
(27, 19, 3, 'Average Quality', 'Average product.', TRUE, 29),
(34, 20, 3, 'Decent Product', 'Average product.', TRUE, 106),
(41, 21, 4, 'Worth the Money', 'Works well and is worth buying.', TRUE, 36),
(48, 22, 5, 'Loved It', 'Would definitely buy again.', TRUE, 53),
(55, 23, 4, 'Very Good', 'Satisfied with the purchase.', TRUE, 78),
(62, 24, 4, 'Very Good', 'Good quality with minor issues.', TRUE, 16),
(69, 25, 5, 'Excellent Product', 'Fantastic product for the price.', TRUE, 83),
(76, 26, 4, 'Very Good', 'Satisfied with the purchase.', TRUE, 115),
(83, 27, 5, 'Amazing Quality', 'Fantastic product for the price.', TRUE, 50),
(90, 28, 5, 'Amazing Quality', 'Fantastic product for the price.', TRUE, 13),
(97, 29, 5, 'Highly Recommended', 'Excellent quality and performance.', TRUE, 7),
(4, 30, 2, 'Not as Expected', 'Expected better quality.', TRUE, 26),
(11, 1, 3, 'Meets Expectations', 'Nothing exceptional but usable.', TRUE, 14),
(18, 2, 3, 'Average Quality', 'It''s okay for the price.', TRUE, 6),
(25, 3, 4, 'Nice Design', 'Good quality with minor issues.', TRUE, 72),
(32, 4, 4, 'Good Packaging', 'Good quality with minor issues.', TRUE, 12),
(39, 5, 2, 'Could Be Better', 'Expected better quality.', TRUE, 3),
(46, 6, 1, 'Disappointed', 'Very disappointing experience.', TRUE, 78),
(53, 7, 3, 'Meets Expectations', 'Average product.', TRUE, 81),
(60, 8, 2, 'Not as Expected', 'Has a few noticeable issues.', TRUE, 77),
(67, 9, 4, 'Worth the Money', 'Satisfied with the purchase.', TRUE, 15),
(74, 10, 5, 'Amazing Quality', 'Fantastic product for the price.', TRUE, 59),
(81, 11, 5, 'Excellent Product', 'Exceeded my expectations.', TRUE, 39),
(88, 12, 2, 'Average Experience', 'Has a few noticeable issues.', TRUE, 13),
(95, 13, 5, 'Value for Money', 'Fantastic product for the price.', TRUE, 94),
(2, 14, 4, 'Nice Design', 'Good quality with minor issues.', TRUE, 106),
(9, 15, 5, 'Highly Recommended', 'Would definitely buy again.', TRUE, 2),
(16, 16, 5, 'Loved It', 'Excellent quality and performance.', TRUE, 18),
(23, 17, 4, 'Very Good', 'Satisfied with the purchase.', TRUE, 97),
(30, 18, 5, 'Excellent Product', 'Would definitely buy again.', TRUE, 82),
(37, 19, 4, 'Good Packaging', 'Works well and is worth buying.', TRUE, 66),
(44, 20, 2, 'Could Be Better', 'Not fully satisfied.', TRUE, 45),
(51, 21, 4, 'Very Good', 'Satisfied with the purchase.', TRUE, 69),
(58, 22, 4, 'Nice Design', 'Good quality with minor issues.', TRUE, 81),
(65, 23, 4, 'Nice Design', 'Works well and is worth buying.', TRUE, 103),
(72, 24, 5, 'Amazing Quality', 'Exceeded my expectations.', TRUE, 104),
(79, 25, 2, 'Average Experience', 'Has a few noticeable issues.', TRUE, 25),
(86, 26, 4, 'Worth the Money', 'Works well and is worth buying.', TRUE, 45),
(93, 27, 4, 'Good Packaging', 'Satisfied with the purchase.', TRUE, 101),
(100, 28, 3, 'Decent Product', 'Nothing exceptional but usable.', TRUE, 33),
(7, 29, 3, 'Meets Expectations', 'Average product.', TRUE, 77),
(14, 30, 3, 'Meets Expectations', 'Average product.', TRUE, 103),
(21, 1, 4, 'Nice Design', 'Works well and is worth buying.', TRUE, 10),
(28, 2, 4, 'Fast Delivery', 'Works well and is worth buying.', TRUE, 29),
(35, 3, 4, 'Nice Design', 'Satisfied with the purchase.', TRUE, 43),
(42, 4, 4, 'Very Good', 'Works well and is worth buying.', TRUE, 79),
(49, 5, 3, 'Meets Expectations', 'Nothing exceptional but usable.', TRUE, 61),
(56, 6, 5, 'Excellent Product', 'Fantastic product for the price.', TRUE, 10),
(63, 7, 1, 'Not Recommended', 'Very disappointing experience.', TRUE, 100),
(70, 8, 4, 'Nice Design', 'Satisfied with the purchase.', TRUE, 61),
(77, 9, 5, 'Value for Money', 'Excellent quality and performance.', TRUE, 101),
(84, 10, 5, 'Amazing Quality', 'Fantastic product for the price.', TRUE, 102),
(91, 11, 2, 'Average Experience', 'Expected better quality.', TRUE, 51),
(98, 12, 1, 'Poor Battery Life', 'Very disappointing experience.', TRUE, 92),
(5, 13, 1, 'Poor Battery Life', 'Very disappointing experience.', TRUE, 16),
(12, 14, 3, 'Good Overall', 'Nothing exceptional but usable.', TRUE, 75),
(19, 15, 5, 'Loved It', 'Fantastic product for the price.', TRUE, 18),
(26, 16, 5, 'Value for Money', 'Exceeded my expectations.', TRUE, 84),
(33, 17, 3, 'Decent Product', 'It''s okay for the price.', TRUE, 70),
(40, 18, 2, 'Average Experience', 'Not fully satisfied.', TRUE, 1),
(47, 19, 4, 'Very Good', 'Good quality with minor issues.', TRUE, 13),
(54, 20, 3, 'Decent Product', 'Average product.', TRUE, 119),
(61, 21, 2, 'Could Be Better', 'Expected better quality.', FALSE, 111),
(68, 22, 5, 'Value for Money', 'Exceeded my expectations.', FALSE, 3),
(75, 23, 5, 'Loved It', 'Exceeded my expectations.', FALSE, 37),
(82, 24, 4, 'Very Good', 'Satisfied with the purchase.', FALSE, 97),
(89, 25, 4, 'Very Good', 'Satisfied with the purchase.', FALSE, 33),
(96, 26, 5, 'Highly Recommended', 'Excellent quality and performance.', FALSE, 106),
(3, 27, 5, 'Value for Money', 'Fantastic product for the price.', FALSE, 116),
(10, 28, 5, 'Loved It', 'Fantastic product for the price.', FALSE, 84),
(17, 29, 4, 'Very Good', 'Works well and is worth buying.', FALSE, 105),
(24, 30, 5, 'Highly Recommended', 'Excellent quality and performance.', FALSE, 68),
(31, 1, 3, 'Good Overall', 'It''s okay for the price.', FALSE, 111),
(38, 2, 4, 'Worth the Money', 'Works well and is worth buying.', FALSE, 77),
(45, 3, 5, 'Highly Recommended', 'Fantastic product for the price.', FALSE, 22),
(52, 4, 3, 'Average Quality', 'Nothing exceptional but usable.', FALSE, 79),
(59, 5, 5, 'Value for Money', 'Fantastic product for the price.', FALSE, 7),
(66, 6, 5, 'Excellent Product', 'Excellent quality and performance.', FALSE, 100),
(73, 7, 3, 'Decent Product', 'Average product.', FALSE, 31),
(80, 8, 4, 'Worth the Money', 'Good quality with minor issues.', FALSE, 5),
(87, 9, 5, 'Loved It', 'Excellent quality and performance.', FALSE, 57),
(94, 10, 4, 'Worth the Money', 'Satisfied with the purchase.', FALSE, 97);