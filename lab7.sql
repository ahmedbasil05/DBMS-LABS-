-- Create and use lab schema 
CREATE DATABASE IF NOT EXISTS retail_db; 
USE retail_db; -- Drop if re-running 
DROP TABLE IF EXISTS OrderItems; 
DROP TABLE IF EXISTS Orders; 
DROP TABLE IF EXISTS Products; 
DROP TABLE IF EXISTS Customers; -- Core tables 
CREATE TABLE Customers ( 
  cust_id    INT PRIMARY KEY, 
  name       VARCHAR(100) NOT NULL, 
  city       VARCHAR(80) 
); 
CREATE TABLE Orders ( 
  order_id    INT PRIMARY KEY, 
  cust_id     INT NOT NULL, 
  order_date  DATE NOT NULL, 
  total_amount DECIMAL(10,2) NOT NULL, 
  FOREIGN KEY (cust_id) REFERENCES Customers(cust_id) 
); 
CREATE TABLE Products ( 
  prod_id   INT PRIMARY KEY, 
  prod_name VARCHAR(120) NOT NULL, 
  category  VARCHAR(80), 
  price     DECIMAL(10,2) NOT NULL 
); 
CREATE TABLE OrderItems ( 
  oi_id      INT PRIMARY KEY, 
  order_id   INT NOT NULL, 
  prod_id    INT NOT NULL, 
  quantity   INT NOT NULL, 
  unit_price DECIMAL(10,2) NOT NULL, 
  FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
  FOREIGN KEY (prod_id)  REFERENCES Products(prod_id) 
); -- Sample data 
INSERT INTO Customers VALUES 
(1,'Ali Khan','Lahore'), 
(2,'Sara Ahmed','Karachi'), 
(3,'John Lee','Islamabad'), 
(4,'Noor Fatima','Lahore');  -- has no orders initially 
INSERT INTO Products VALUES 
(101,'USB-C Cable','Accessories',  800.00), 
(102,'Wireless Mouse','Accessories',2200.00), 
(103,'27-inch Monitor','Displays', 48000.00), 
(104,'Mechanical Keyboard','Accessories',9500.00), 
(105,'Webcam HD','Cameras', 5200.00); 
INSERT INTO Orders VALUES 
(5001,1,'2025-09-20',  8800.00), 
(5002,1,'2025-09-28', 10200.00), 
(5003,2,'2025-10-02',  5200.00), 
(5004,3,'2025-10-04', 22000.00); 
INSERT INTO OrderItems VALUES 
(1,5001,101,2,800.00),     -- 1600 
(2,5001,102,1,2200.00),    -- 2200 
(3,5001,104,1,9500.00),    -- 9500  
(4,5002,103,1,48000.00),   -- 48000 
(5,5003,105,1,5200.00),    -- 5200 
(6,5004,102,2,2200.00),    -- 4400 
(7,5004,103,1,48000.00);   -- 48000 


-- Task 01
SELECT c.cust_id, c.name, o.order_id, o.order_date, o.total_amount 
FROM Customers c 
JOIN Orders o ON o.cust_id = c.cust_id 
ORDER BY c.cust_id, o.order_date; 

-- Task 02
SELECT c.cust_id, c.name, o.order_id, o.order_date 
FROM Customers c 
LEFT JOIN Orders o ON o.cust_id = c.cust_id 
ORDER BY c.cust_id, o.order_date; 

-- Task 03
SELECT o.order_id, o.order_date, c.name AS customer, 
       p.prod_name, oi.quantity, oi.unit_price, 
       (oi.quantity * oi.unit_price) AS line_total 
FROM Orders o 
JOIN Customers c  ON c.cust_id = o.cust_id 
JOIN OrderItems oi ON oi.order_id = o.order_id 
JOIN Products p   ON p.prod_id  = oi.prod_id 
ORDER BY o.order_id, p.prod_name; 

-- Task 04
SELECT c.cust_id, c.name, 
       SUM(oi.quantity * oi.unit_price) AS total_spent 
FROM Customers c 
JOIN Orders o     ON o.cust_id = c.cust_id 
JOIN OrderItems oi ON oi.order_id = o.order_id 
GROUP BY c.cust_id, c.name 
ORDER BY total_spent DESC; 

-- Task 05
SELECT c.cust_id, c.name, 
       SUM(oi.quantity * oi.unit_price) AS total_spent 
FROM Customers c 
JOIN Orders o     ON o.cust_id = c.cust_id 
JOIN OrderItems oi ON oi.order_id = o.order_id 
GROUP BY c.cust_id, c.name 
HAVING SUM(oi.quantity * oi.unit_price) > 20000 
ORDER BY total_spent DESC; 

-- Task 06
SELECT p.prod_id, p.prod_name, 
       SUM(oi.quantity) AS units_sold 
FROM Products p 
JOIN OrderItems oi ON oi.prod_id = p.prod_id 
GROUP BY p.prod_id, p.prod_name 
ORDER BY units_sold DESC, p.prod_name;

-- Task 07
-- Products purchased by customer 'Ali Khan' 
SELECT DISTINCT p.prod_id, p.prod_name, p.category 
FROM Products p 
WHERE p.prod_id IN ( 
  SELECT oi.prod_id 
  FROM OrderItems oi 
  JOIN Orders o ON o.order_id = oi.order_id 
  JOIN Customers c ON c.cust_id = o.cust_id 
  WHERE c.name = 'Ali Khan' 
) 
ORDER BY p.prod_name;  

-- Task 08
SELECT o.order_id, c.name, o.total_amount 
FROM Orders o 
JOIN Customers c ON c.cust_id = o.cust_id 
WHERE o.total_amount > 
      (SELECT AVG(o2.total_amount) 
       FROM Orders o2 
       WHERE o2.cust_id = o.cust_id) 
ORDER BY c.name, o.total_amount DESC;

-- Task 09
SELECT c.cust_id, c.name 
FROM Customers c 
WHERE EXISTS ( 
  SELECT 1 
  FROM Orders o 
  JOIN OrderItems oi ON oi.order_id = o.order_id 
  JOIN Products p    ON p.prod_id = oi.prod_id 
  WHERE o.cust_id = c.cust_id 
    AND p.category = 'Accessories' 
) 
ORDER BY c.cust_id; 

-- Task 10
SELECT p.prod_id, p.prod_name, p.category 
FROM Products p 
WHERE NOT EXISTS ( 
SELECT 1 
FROM OrderItems oi 
WHERE oi.prod_id = p.prod_id 
) 
ORDER BY p.prod_name; 