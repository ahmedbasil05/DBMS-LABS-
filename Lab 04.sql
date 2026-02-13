
CREATE DATABASE LAB04;
USE LAB04;

-- Task 01
CREATE TABLE CUSTOMER (
 customer_id INT PRIMARY KEY, 
 cust_name VARCHAR(20), 
 email VARCHAR(50) UNIQUE, 
 phone INT
);

SELECT * FROM CUSTOMER;

-- Task 02
CREATE TABLE PRODUCT (
 product_id INT PRIMARY KEY, 
 product_name VARCHAR(50), 
 price INT CHECK (price > 0), 
 stock INT
); 

SELECT * FROM PRODUCT;

-- Task 03
CREATE TABLE ORDERTABLE (
  order_id INT PRIMARY KEY, 
  order_date DATE,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES CUSTOMER (customer_id)
);

SELECT * FROM ORDERTABLE;

-- Task 04
ALTER TABLE ORDERTABLE ADD status VARCHAR(50) DEFAULT 'pending';

-- Task 05
CREATE TABLE ORDERITEM (
 order_id INT, 
 product_id INT, 
 quantity INT,
 FOREIGN KEY (order_id) REFERENCES ORDERTABLE(order_id),
 FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
 PRIMARY KEY(order_id,product_id)
); 

SELECT * FROM ORDERITEM;

-- Task 06
CREATE TABLE EMPLOYEE (
 emp_id INT PRIMARY KEY, 
 e_name VARCHAR(50), 
 e_role VARCHAR(50), 
 hire_date DATE CHECK (hire_date <= '2025-09-29')
); 


-- Task 07
SHOW TABLES;

-- Task 08
DROP TABLE IF EXISTS ORDERITEM;

CREATE TABLE ORDERITEM (
 order_id INT, 
 product_id INT, 
 quantity INT,
 FOREIGN KEY (order_id) REFERENCES ORDERTABLE(order_id),
 FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
 PRIMARY KEY(order_id,product_id)
);

-- Task 09
ALTER TABLE PRODUCT ADD COLUMN CATEGORY VARCHAR(50);

-- Task 10

-- CHALLENGE TASKS

-- Task 01
CREATE TABLE SUPPLIER (
 sup_id INT PRIMARY KEY,
 sup_name VARCHAR(50),
 product_id INT,
 FOREIGN KEY (product_id) REFERENCES PRODUCT (product_id)
 );
 
 -- Task 02
 ALTER TABLE EMPLOYEE MODIFY e_role VARCHAR(50) CHECK (e_role IN ('Manager', 'Cashier','Stocker'));
 
 -- Task 03
 ALTER TABLE ORDERITEM MODIFY quantity INT CHECK ( quantity > 0);
 
 -- Task 04
 DROP TABLE IF EXISTS ORDERITEM;
 DROP TABLE IF EXISTS ORDERTABLE;
 DROP TABLE IF EXISTS CUSTOMER;
 
CREATE TABLE CUSTOMER (
 customer_id INT PRIMARY KEY, 
 cust_name VARCHAR(20), 
 email VARCHAR(50) UNIQUE, 
 phone INT,
 address VARCHAR(50)
);

SELECT * FROM CUSTOMER;

 
  -- Task 05
  ALTER TABLE ORDERTABLE RENAME COLUMN STATUS TO order_status;
  
  SELECT * FROM ORDERTABLE;
  



 