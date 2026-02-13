CREATE TABLE `supplier` (
  `supplier_id` int PRIMARY KEY,
  `name` varchar(100),
  `phone` varchar(20) UNIQUE,
  `address` varchar(150)
);

CREATE TABLE `product` (
  `product_id` int PRIMARY KEY,
  `name` varchar(100),
  `category` varchar(50),
  `price` decimal(10,2)
);

CREATE TABLE `warehouse` (
  `warehouse_id` int PRIMARY KEY,
  `location` varchar(150)
);

CREATE TABLE `record` (
  `supplier_id` int,
  `product_id` int,
  `warehouse_id` int,
  `quantity` int,
  `supply_date` date
);

ALTER TABLE `record` ADD FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`);

ALTER TABLE `record` ADD FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

ALTER TABLE `record` ADD FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`warehouse_id`);
