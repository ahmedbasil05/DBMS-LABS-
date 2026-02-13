USE lab7;
-- Lab Guided Tasks
-- Task 01: Baseline query with EXPLAIN
EXPLAIN
SELECT o.order_id, o.order_date, c.name AS customer,
       p.category, p.prod_name, oi.quantity, oi.unit_price
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
JOIN OrderItems oi ON oi.order_id = o.order_id
JOIN Products p ON p.prod_id = oi.prod_id
WHERE p.category = 'Accessories'
  AND o.order_date BETWEEN '2025-09-01' AND '2025-10-31'
ORDER BY o.order_date DESC;

-- Task 02: Create and use view
CREATE VIEW v_customer_orders AS
SELECT o.order_id, o.order_date, o.cust_id, c.name AS customer,
o.total_amount
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id; 
SELECT * FROM v_customer_orders ORDER BY order_date DESC;

-- Task 03: Customer spend view
CREATE VIEW v_customer_spend AS
SELECT c.cust_id, c.name,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customers c
JOIN Orders o ON o.cust_id = c.cust_id
JOIN OrderItems oi ON oi.order_id = o.order_id
GROUP BY c.cust_id, c.name;

SELECT * FROM v_customer_spend ORDER BY total_spent DESC;

-- Task 04: Updatable view with CHECK OPTION
CREATE VIEW v_products_basic AS
SELECT prod_id, prod_name, category, price
FROM Products
WHERE price >= 0
WITH CHECK OPTION;

-- Allowed update
UPDATE v_products_basic
SET price = price + 100
WHERE prod_id = 101;


-- Task 05: Index on order_date and re-explain
CREATE INDEX idx_orders_order_date ON Orders(order_date);

EXPLAIN
SELECT o.order_id, o.order_date, c.name, p.prod_name
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
JOIN OrderItems oi ON oi.order_id = o.order_id
JOIN Products p ON p.prod_id = oi.prod_id
WHERE o.order_date BETWEEN '2025-09-01' AND '2025-10-31'
ORDER BY o.order_date DESC;

-- Task 06: Composite index on OrderItems
CREATE INDEX idx_orderitems_order_prod
ON OrderItems(order_id, prod_id);

EXPLAIN
SELECT o.order_id, p.prod_name, SUM(oi.quantity) AS units
FROM Orders o
JOIN OrderItems oi ON oi.order_id = o.order_id
JOIN Products p ON p.prod_id = oi.prod_id
GROUP BY o.order_id, p.prod_name
ORDER BY o.order_id;

-- Task 07: Covering index on Products
CREATE INDEX idx_products_category_name_price
ON Products(category, prod_name, price);

EXPLAIN
SELECT prod_name, price
FROM Products
WHERE category = 'Accessories'
ORDER BY prod_name;

-- Task 08: Compare IN vs EXISTS
EXPLAIN
SELECT p.prod_id, p.prod_name
FROM Products p
WHERE p.prod_id IN (
    SELECT oi.prod_id
    FROM OrderItems oi
);

EXPLAIN
SELECT p.prod_id, p.prod_name
FROM Products p
WHERE EXISTS (
    SELECT 1
    FROM OrderItems oi
    WHERE oi.prod_id = p.prod_id
);

-- Task 09: EXPLAIN ANALYZE 
EXPLAIN ANALYZE
SELECT c.cust_id, c.name,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customers c
JOIN Orders o ON o.cust_id = c.cust_id
JOIN OrderItems oi ON oi.order_id = o.order_id
GROUP BY c.cust_id, c.name
ORDER BY total_spent DESC;

-- Task 10: Refresh stats and drop index 
ANALYZE TABLE Orders, OrderItems, Products;
ALTER TABLE Orders DROP INDEX idx_orders_order_date;
EXPLAIN
SELECT o.order_id, o.order_date
FROM Orders o
WHERE o.order_date BETWEEN '2025-09-01' AND '2025-10-31'
ORDER BY o.order_date DESC;

-- Challange Tasks 
-- Task 01 
-- Create view for recent orders (last 30 days)
CREATE VIEW v_recent_orders AS
SELECT o.order_id, o.order_date, c.name AS customer,
       o.total_amount
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY;

-- Query the view
SELECT * FROM v_recent_orders ORDER BY order_date DESC;

-- Task 02 
-- Create composite index: (cust_id, order_date DESC)
CREATE INDEX idx_orders_cust_date_desc ON Orders(cust_id, order_date DESC);

-- Test query that benefits from this index
EXPLAIN
SELECT o.order_id, o.order_date, c.name AS customer, o.total_amount
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
WHERE o.cust_id = 1
  AND o.order_date BETWEEN '2025-09-01' AND '2025-10-31'
ORDER BY o.order_date DESC;

EXPLAIN
SELECT o.order_id, o.order_date, c.name
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
WHERE YEAR(o.order_date) = 2025
  AND MONTH(o.order_date) = 10;
  
 -- Task 03 
  -- Sargable: uses direct date range — index-friendly
EXPLAIN
SELECT o.order_id, o.order_date, c.name
FROM Orders o
JOIN Customers c ON c.cust_id = o.cust_id
WHERE o.order_date >= '2025-10-01'
AND o.order_date < '2025-11-01';
  
-- Task 4
  -- Create covering index for the query
CREATE INDEX idx_products_cameras_name_price
ON Products(category, prod_name, price);

-- Query that should be covered (no table access needed)
EXPLAIN
SELECT prod_name, price
FROM Products
WHERE category = 'Cameras'
ORDER BY prod_name;

-- Task 5 
-- Create reusable view for customer spend
CREATE VIEW v_customer_total_spend AS
SELECT c.cust_id, c.name,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customers c
JOIN Orders o ON o.cust_id = c.cust_id
JOIN OrderItems oi ON oi.order_id = o.order_id
GROUP BY c.cust_id, c.name;

-- Filter high-value customers (> 20,000) using the view
SELECT *
FROM v_customer_total_spend
WHERE total_spent > 20000
ORDER BY total_spent DESC;