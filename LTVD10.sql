
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    role ENUM('admin', 'customer') NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    stock_quantity INT,
    image_url TEXT,
    is_visible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('chờ xác nhận', 'đã xác nhận', 'đang giao', 'đã giao', 'huỷ'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Thêm users
INSERT INTO users (username, email, password, role) VALUES
('admin1', 'admin1@example.com', 'pass1', 'admin'),
('cust1', 'cust1@example.com', 'pass1', 'customer'),
('cust2', 'cust2@example.com', 'pass2', 'customer'),
-- thêm đến 10 dòng...

-- Thêm customers
INSERT INTO customers (user_id, full_name, phone, address) VALUES
(2, 'Nguyễn Văn A', '0900000001', 'Hà Nội'),
(3, 'Trần Thị B', '0900000002', 'Hồ Chí Minh'),
-- thêm đến 10 dòng...

-- Thêm categories
INSERT INTO categories (category_name) VALUES
('Điện thoại'), ('Laptop'), ('Phụ kiện'), ('Máy tính bảng'), ('Đồng hồ'),
('Thiết bị mạng'), ('Camera'), ('Loa'), ('USB'), ('Màn hình');

-- Thêm products
INSERT INTO products (category_id, name, description, price, stock_quantity, image_url, is_visible) VALUES
(1, 'iPhone 14', 'Điện thoại Apple', 20000000, 5, 'iphone.jpg', TRUE),
(2, 'MacBook Air', 'Laptop Apple', 30000000, 8, 'macbook.jpg', TRUE),
-- thêm đến 10 dòng...

-- Thêm orders
INSERT INTO orders (customer_id, status) VALUES
(1, 'đã giao'),
(1, 'huỷ'),
(2, 'đã giao'),
-- thêm đến 10 dòng...

-- Thêm order_details
INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 19500000),
(1, 2, 1, 29000000),
-- thêm đến 10 dòng...

SELECT o.order_id, o.order_date, o.status,
       c.full_name, c.phone, c.address,
       SUM(od.quantity * od.price) AS total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id;

SELECT p.*
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.category_name = 'Điện thoại' AND p.stock_quantity < 10;

SELECT c.category_name, SUM(od.quantity * od.price) AS revenue
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.status = 'đã giao'
GROUP BY c.category_name;

UPDATE orders
SET status = 'đã giao'
WHERE order_id = 1;  -- thay 1 bằng ID đơn hàng cần cập nhật

DELETE FROM orders
WHERE status = 'huỷ'
  AND order_id NOT IN (SELECT DISTINCT order_id FROM order_details);

SELECT c.full_name, SUM(od.quantity * od.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
WHERE o.status = 'đã giao'
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

SELECT *
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_details);

SELECT status, COUNT(*) AS total_orders
FROM orders
GROUP BY status;

SELECT o.order_id, SUM(od.quantity * od.price) AS total_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE MONTH(o.order_date) = 3 AND YEAR(o.order_date) = 2025
GROUP BY o.order_id
ORDER BY total_value DESC
LIMIT 1;

UPDATE products p
JOIN (
    SELECT od.product_id, SUM(od.quantity) AS total_sold
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    WHERE o.status = 'đã giao'
    GROUP BY od.product_id
) AS sold ON p.product_id = sold.product_id
SET p.stock_quantity = p.stock_quantity - sold.total_sold;
