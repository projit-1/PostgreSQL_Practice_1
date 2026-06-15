CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE,
    customer_segment VARCHAR(30),
    email VARCHAR(100) UNIQUE
);

select * from customers;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price NUMERIC(10,2),
    cost_price NUMERIC(10,2),
    supplier_id INT,
    stock_qty INT,
    launch_year INT
);

select * from products;



