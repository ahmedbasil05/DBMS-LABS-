CREATE DATABASE LAB05;
USE LAB05;

 -- TASK 01
CREATE TABLE Customer ( 
customer_id INT PRIMARY KEY, 
name VARCHAR(100) NOT NULL, 
email VARCHAR(100) NOT NULL UNIQUE, 
phone VARCHAR(20) 
);

SELECT * FROM Customer;

-- TASK 02
CREATE TABLE Product ( 
product_id INT PRIMARY KEY, 
product_name VARCHAR(100) NOT NULL, 
price DECIMAL(10,2) CHECK (price > 0), 
stock INT DEFAULT 0 
); 

SELECT * FROM Product;

-- TASK 03
CREATE TABLE Orders ( 
order_id INT PRIMARY KEY, 
order_date DATE, 
customer_id INT, 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) 
); 

SELECT * FROM Orders;

-- TASK 04
ALTER TABLE Orders
DROP FOREIGN KEY Orders_ibfk_1; 
 
ALTER TABLE Orders 
ADD CONSTRAINT fk_customer 
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

SELECT * FROM Orders;

-- TASK 05
CREATE TABLE OrderItem ( 
    order_id INT, 
    product_id INT, 
    quantity INT CHECK (quantity >= 1), 
    PRIMARY KEY (order_id, product_id), 
    FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
    FOREIGN KEY (product_id) REFERENCES Product(product_id) 
);

SELECT * FROM OrderItem;
-- TASK 06
CREATE TABLE Employee ( 
emp_id INT PRIMARY KEY, 
name VARCHAR(100) NOT NULL, 
role ENUM('Manager','Cashier','Stocker'), 
hire_date DATE DEFAULT ( CURRENT_DATE) 
); 

SELECT * FROM Employee;

-- TASK 07
ALTER TABLE Orders 
ADD status VARCHAR(20) DEFAULT 'Pending'; 

SELECT * FROM Orders;

-- TASK 08
SHOW TABLES; 
DESCRIBE Orders; 
SHOW CREATE TABLE OrderItem; 

-- TASK 09
-- valid
INSERT INTO Customer VALUES (1, 'Alice', 'alice@example.com', 
'12345'); 
-- Invalid: duplicate email 
INSERT INTO Customer VALUES (2, 'Bob', 'alice@example.com', '67890'); 

SELECT * FROM Customer;

-- TASK 10
ALTER TABLE Orders 
MODIFY status VARCHAR(20) NOT NULL DEFAULT 'Pending'; 
ALTER TABLE Orders 
CHANGE status order_status VARCHAR(20) NOT NULL; 

SELECT * FROM Orders;

-- CHALLENGE TASKS

-- TASK 01
CREATE TABLE SUPPLIER (
SUP_ID INT PRIMARY KEY,
SUP_NAME VARCHAR(20) NOT NULL
);
ALTER TABLE Product ADD COLUMN supplier_id INT;
SELECT *FROM Product;

ALTER TABLE Product ADD CONSTRAINT fk_supplier
FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
ON DELETE SET NULL;

SELECT *FROM SUPPLIER;

-- TASK 02
ALTER TABLE Product ADD CONSTRAINT check_neg CHECK (stock>=0);
SELECT * FROM Product;

-- TASK 03
DELIMITER $$

CREATE TRIGGER check_quantity_before_insert
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;

    -- Get the current stock for the product being ordered
    SELECT stock INTO available_stock
    FROM Product
    WHERE product_id = NEW.product_id;

    -- If ordered quantity exceeds stock, raise an error
    IF NEW.quantity > available_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order quantity exceeds available stock';
    END IF;
END $$

DELIMITER ;


-- TASK 04
ALTER TABLE Employee
RENAME COLUMN hire_date TO date_hired;

SELECT * FROM Employee;

-- TASK 05
ALTER TABLE OrderItem
DROP FOREIGN KEY fk_orderitem_orders;

ALTER TABLE OrderItem
ADD CONSTRAINT fk_orderitem_orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id)
ON DELETE CASCADE;

SELECT * FROM OrderItem;


