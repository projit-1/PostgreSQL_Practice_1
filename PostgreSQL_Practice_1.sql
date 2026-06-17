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


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(20),
    payment_method VARCHAR(30),
    shipping_city VARCHAR(50),
    shipping_cost NUMERIC(10,2),
    discount NUMERIC(5,2),
    tax_amount NUMERIC(10,2),
    sales_rep_id INT,

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

select * from orders;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price NUMERIC(10,2),
    discount_amount NUMERIC(10,2),
    total_amount NUMERIC(12,2),
    warehouse_id INT,
    delivery_days INT,
    returned_flag BOOLEAN,

    CONSTRAINT fk_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

select * from order_items;

-- 1. Total Customers --

select count (*) from customers;


-- 2. Total orders --

SELECT COUNT(*) FROM orders;

-- 3. Customers by City --

SELECT city, COUNT(*) as total_customers FROM customers 
GROUP BY city order by total_customers asc;

-- 4. Average customer age

SELECT ROUND(AVG(age)::numeric, 2)
FROM customers;

-- 5. Top 10 customers by orders

SELECT customer_id, COUNT(*) orders_count
FROM orders
GROUP BY customer_id
ORDER BY orders_count DESC
LIMIT 10;

-- 6. Total sales by product category

SELECT p.category, SUM(oi.total_amount)
FROM order_items oi
JOIN products p ON oi.product_id=p.product_id
GROUP BY p.category;

-- 7. Top 10 products by revenue

SELECT p.product_name, SUM(oi.total_amount) revenue
FROM order_items oi
JOIN products p ON oi.product_id=p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 8. Monthly revenue

SELECT DATE_TRUNC('month', o.order_date) AS month,
       SUM(oi.total_amount) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1;

-- 9. Average order value

SELECT round(AVG(total_amount)::numeric,2)  FROM order_items;

-- 10. Highest spending customer

SELECT c.customer_id, c.first_name,
SUM(oi.total_amount) spend
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY c.customer_id,c.first_name
ORDER BY spend DESC
LIMIT 1;


-- 11. Orders by status

SELECT order_status, COUNT(*) FROM orders GROUP BY order_status;

-- 12. Revenue by city

SELECT o.shipping_city, SUM(oi.total_amount)
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY o.shipping_city;

-- 13. Products never ordered

SELECT product_id, product_name
FROM products
WHERE product_id NOT IN
(SELECT DISTINCT product_id FROM order_items);

-- 14. Average delivery days by warehouse

SELECT warehouse_id, round(AVG(delivery_days)::numeric,2) as avg_delivery
FROM order_items
GROUP BY warehouse_id order by avg_delivery desc limit 5;

-- 15. Return rate

SELECT ROUND(
    AVG(CASE WHEN returned_flag THEN 1 ELSE 0 END) * 100,
    2
) AS return_rate
FROM order_items;

-- 16. Top brand by revenue

SELECT p.brand, SUM(oi.total_amount) revenue
FROM products p
JOIN order_items oi ON p.product_id=oi.product_id
GROUP BY p.brand
ORDER BY revenue DESC
LIMIT 1;

-- 17. Running revenue

SELECT order_id,
SUM(total_amount) OVER(ORDER BY order_id)
FROM order_items;

-- 18. Rank customers by spending

SELECT customer_id,
SUM(oi.total_amount) spend,
RANK() OVER(ORDER BY SUM(oi.total_amount) DESC)
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY customer_id;

-- 19. Customers with >5 orders

SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*)>5;

-- 20. Revenue after discount

SELECT SUM(total_amount-discount_amount)
FROM order_items;

-- 21. Most popular payment method

SELECT payment_method, COUNT(*)
FROM orders
GROUP BY payment_method
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 22. Yearly revenue

SELECT EXTRACT(YEAR FROM order_date) yr,
SUM(oi.total_amount)
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY yr;


-- 23. Customer lifetime value

SELECT customer_id, SUM(oi.total_amount) as amount
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY customer_id order by amount desc;


-- 24. Top category in each city

SELECT shipping_city, category, revenue
FROM (
SELECT o.shipping_city,p.category,
SUM(oi.total_amount) revenue,
RANK() OVER(PARTITION BY o.shipping_city ORDER BY SUM(oi.total_amount) DESC) rnk
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
JOIN products p ON oi.product_id=p.product_id
GROUP BY o.shipping_city,p.category
)x
WHERE rnk=1;


-- 25. Create sales view

CREATE VIEW sales_summary AS
SELECT o.order_id,o.customer_id,
SUM(oi.total_amount) revenue
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY o.order_id,o.customer_id;


----

SELECT * FROM sales_summary;

