USE inventory_management;

-- =====================================================
-- Sample Data for Inventory and Order Management System
-- =====================================================
-- This file contains realistic test data for all tables
-- Compatible with the enterprise-level schema
-- =====================================================

-- =====================================================
-- Customers (20 records)
-- =====================================================
INSERT INTO Customers (full_name, email, phone, shipping_address) VALUES
('John Smith', 'john.smith@email.com', '555-0101', '123 Oak Street, Boston, MA 02108'),
('Emily Johnson', 'emily.j@email.com', '555-0102', '456 Maple Ave, New York, NY 10001'),
('Michael Brown', 'michael.brown@email.com', '555-0103', '789 Pine Road, Chicago, IL 60601'),
('Sarah Davis', 'sarah.davis@email.com', '555-0104', '321 Elm Street, Los Angeles, CA 90001'),
('David Wilson', 'david.wilson@email.com', '555-0105', '654 Cedar Lane, Houston, TX 77001'),
('Jennifer Martinez', 'jennifer.m@email.com', '555-0106', '987 Birch Drive, Phoenix, AZ 85001'),
('Robert Taylor', 'robert.taylor@email.com', '555-0107', '147 Walnut Court, Philadelphia, PA 19019'),
('Lisa Anderson', 'lisa.anderson@email.com', '555-0108', '258 Cherry Street, San Antonio, TX 78201'),
('James Thomas', 'james.thomas@email.com', '555-0109', '369 Spruce Avenue, San Diego, CA 92101'),
('Patricia Jackson', 'patricia.j@email.com', '555-0110', '741 Ash Boulevard, Dallas, TX 75201'),
('Christopher White', 'chris.white@email.com', '555-0111', '852 Poplar Lane, San Jose, CA 95101'),
('Barbara Harris', 'barbara.harris@email.com', '555-0112', '963 Willow Way, Austin, TX 78701'),
('Daniel Clark', 'daniel.clark@email.com', '555-0113', '159 Redwood Drive, Jacksonville, FL 32099'),
('Nancy Lewis', 'nancy.lewis@email.com', '555-0114', '357 Cypress Court, Fort Worth, TX 76101'),
('Matthew Robinson', 'matt.robinson@email.com', '555-0115', '486 Magnolia Street, Columbus, OH 43085'),
('Karen Walker', 'karen.walker@email.com', '555-0116', '753 Hickory Avenue, Charlotte, NC 28201'),
('Paul Young', 'paul.young@email.com', '555-0117', '951 Beech Road, San Francisco, CA 94102'),
('Betty Allen', 'betty.allen@email.com', '555-0118', '246 Sycamore Lane, Indianapolis, IN 46201'),
('Mark King', 'mark.king@email.com', '555-0119', '135 Dogwood Drive, Seattle, WA 98101'),
('Sandra Wright', 'sandra.wright@email.com', '555-0120', '864 Fir Street, Denver, CO 80201');

-- =====================================================
-- Products (25 records across 5 categories)
-- =====================================================
INSERT INTO Products (product_name, category, price, description, is_active) VALUES
-- Electronics (5 products)
('Wireless Bluetooth Headphones', 'Electronics', 79.99, 'Premium noise-canceling over-ear headphones', TRUE),
('Smart Watch Pro', 'Electronics', 299.99, 'Fitness tracking smartwatch with GPS', TRUE),
('USB-C Hub Adapter', 'Electronics', 49.99, '7-in-1 multiport adapter', TRUE),
('Portable Power Bank 20000mAh', 'Electronics', 39.99, 'Fast charging portable battery', TRUE),
('4K Webcam', 'Electronics', 129.99, 'High-definition webcam for streaming', TRUE),

-- Apparel (5 products)
('Men\'s Cotton T-Shirt', 'Apparel', 24.99, 'Comfortable 100% cotton t-shirt', TRUE),
('Women\'s Running Shoes', 'Apparel', 89.99, 'Lightweight athletic shoes', TRUE),
('Classic Denim Jeans', 'Apparel', 59.99, 'Premium stretch denim jeans', TRUE),
('Winter Hooded Jacket', 'Apparel', 119.99, 'Waterproof insulated jacket', TRUE),
('Athletic Yoga Pants', 'Apparel', 44.99, 'High-waist moisture-wicking leggings', TRUE),

-- Books (5 products)
('The Art of SQL Mastery', 'Books', 34.99, 'Comprehensive guide to database design', TRUE),
('Python Programming Complete', 'Books', 42.99, 'From beginner to advanced Python', TRUE),
('Digital Marketing Essentials', 'Books', 29.99, 'Modern marketing strategies', TRUE),
('Data Science Handbook', 'Books', 54.99, 'Practical data analysis techniques', TRUE),
('Leadership Principles', 'Books', 27.99, 'Building effective teams', TRUE),

-- Home & Garden (5 products)
('Stainless Steel Cookware Set', 'Home & Garden', 159.99, '12-piece professional cookware', TRUE),
('Memory Foam Pillow', 'Home & Garden', 39.99, 'Ergonomic neck support pillow', TRUE),
('LED Desk Lamp', 'Home & Garden', 34.99, 'Adjustable brightness desk lamp', TRUE),
('Indoor Plant Collection', 'Home & Garden', 49.99, 'Set of 3 low-maintenance plants', TRUE),
('Cotton Bed Sheet Set', 'Home & Garden', 64.99, 'Queen size 400 thread count sheets', TRUE),

-- Sports (5 products)
('Yoga Mat with Carry Strap', 'Sports', 29.99, 'Non-slip 6mm thick mat', TRUE),
('Adjustable Dumbbells Set', 'Sports', 199.99, '50lb adjustable weight set', TRUE),
('Resistance Bands Kit', 'Sports', 24.99, 'Set of 5 resistance levels', TRUE),
('Soccer Ball Official Size', 'Sports', 19.99, 'FIFA approved soccer ball', TRUE),
('Camping Tent 4-Person', 'Sports', 149.99, 'Waterproof camping tent', TRUE);

-- =====================================================
-- Inventory (25 records - one per product)
-- Includes reorder_level and last_restock_date
-- =====================================================
INSERT INTO Inventory (product_id, quantity_on_hand, reorder_level, last_restock_date) VALUES
(1, 45, 20, '2024-01-10'), (2, 28, 15, '2024-01-08'), (3, 67, 30, '2024-01-12'),
(4, 89, 40, '2024-01-15'), (5, 34, 15, '2024-01-05'),
(6, 120, 50, '2024-01-18'), (7, 56, 25, '2024-01-20'), (8, 78, 35, '2024-01-10'),
(9, 42, 20, '2024-01-12'), (10, 95, 40, '2024-01-15'),
(11, 150, 60, '2024-01-05'), (12, 88, 40, '2024-01-08'), (13, 72, 30, '2024-01-10'),
(14, 65, 30, '2024-01-12'), (15, 110, 50, '2024-01-15'),
(16, 38, 20, '2024-01-02'), (17, 125, 50, '2024-01-05'), (18, 92, 40, '2024-01-08'),
(19, 76, 35, '2024-01-10'), (20, 54, 25, '2024-01-12'),
(21, 105, 50, '2024-01-15'), (22, 31, 15, '2024-01-18'), (23, 68, 30, '2024-01-20'),
(24, 143, 60, '2024-01-22'), (25, 27, 15, '2024-01-25');

-- =====================================================
-- Orders (30 records with various statuses)
-- Includes shipping_date and delivery_date where applicable
-- =====================================================
INSERT INTO Orders (customer_id, order_date, total_amount, order_status, shipping_date, delivery_date) VALUES
(1, '2024-01-15', 109.98, 'Delivered', '2024-01-16', '2024-01-20'),
(2, '2024-01-18', 299.99, 'Delivered', '2024-01-19', '2024-01-23'),
(3, '2024-02-05', 154.97, 'Delivered', '2024-02-06', '2024-02-10'),
(4, '2024-02-12', 89.99, 'Shipped', '2024-02-13', NULL),
(5, '2024-02-20', 247.96, 'Delivered', '2024-02-21', '2024-02-25'),
(6, '2024-03-03', 79.99, 'Delivered', '2024-03-04', '2024-03-08'),
(7, '2024-03-10', 194.97, 'Shipped', '2024-03-11', NULL),
(8, '2024-03-15', 329.98, 'Delivered', '2024-03-16', '2024-03-20'),
(9, '2024-04-01', 84.98, 'Delivered', '2024-04-02', '2024-04-06'),
(10, '2024-04-08', 412.95, 'Delivered', '2024-04-09', '2024-04-13'),
(11, '2024-04-22', 129.99, 'Shipped', '2024-04-23', NULL),
(12, '2024-05-05', 167.97, 'Delivered', '2024-05-06', '2024-05-10'),
(13, '2024-05-14', 199.99, 'Delivered', '2024-05-15', '2024-05-19'),
(14, '2024-05-28', 94.98, 'Shipped', '2024-05-29', NULL),
(15, '2024-06-03', 289.97, 'Delivered', '2024-06-04', '2024-06-08'),
(1, '2024-06-15', 224.97, 'Delivered', '2024-06-16', '2024-06-20'),
(3, '2024-06-22', 314.96, 'Shipped', '2024-06-23', NULL),
(5, '2024-07-01', 149.99, 'Delivered', '2024-07-02', '2024-07-06'),
(7, '2024-07-10', 179.98, 'Delivered', '2024-07-11', '2024-07-15'),
(9, '2024-07-18', 254.96, 'Shipped', '2024-07-19', NULL),
(2, '2024-08-02', 369.97, 'Delivered', '2024-08-03', '2024-08-07'),
(4, '2024-08-12', 119.98, 'Delivered', '2024-08-13', '2024-08-17'),
(6, '2024-08-25', 449.95, 'Shipped', '2024-08-26', NULL),
(8, '2024-09-05', 159.98, 'Delivered', '2024-09-06', '2024-09-10'),
(10, '2024-09-14', 274.97, 'Delivered', '2024-09-15', '2024-09-19'),
(12, '2024-09-28', 89.99, 'Pending', NULL, NULL),
(14, '2024-10-08', 384.96, 'Pending', NULL, NULL),
(15, '2024-10-15', 209.98, 'Pending', NULL, NULL),
(16, '2024-10-22', 139.98, 'Pending', NULL, NULL),
(18, '2024-10-30', 324.97, 'Pending', NULL, NULL);

-- =====================================================
-- Order_Items (67 records linking orders to products)
-- =====================================================
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase, discount_amount) VALUES
-- Order 1 (Customer 1)
(1, 1, 1, 79.99, 0.00),
(1, 21, 1, 29.99, 0.00),
-- Order 2 (Customer 2)
(2, 2, 1, 299.99, 0.00),
-- Order 3 (Customer 3)
(3, 6, 2, 24.99, 0.00),
(3, 11, 1, 34.99, 0.00),
(3, 13, 2, 29.99, 0.00),
-- Order 4 (Customer 4)
(4, 7, 1, 89.99, 0.00),
-- Order 5 (Customer 5)
(5, 3, 2, 49.99, 0.00),
(5, 12, 1, 42.99, 0.00),
(5, 17, 2, 39.99, 0.00),
-- Order 6 (Customer 6)
(6, 1, 1, 79.99, 0.00),
-- Order 7 (Customer 7)
(7, 16, 1, 159.99, 0.00),
(7, 18, 1, 34.99, 0.00),
-- Order 8 (Customer 8)
(8, 2, 1, 299.99, 0.00),
(8, 21, 1, 29.99, 0.00),
-- Order 9 (Customer 9)
(9, 24, 2, 19.99, 0.00),
(9, 6, 1, 24.99, 0.00),
-- Order 10 (Customer 10)
(10, 8, 2, 59.99, 0.00),
(10, 10, 1, 44.99, 0.00),
(10, 14, 1, 54.99, 0.00),
(10, 22, 1, 199.99, 0.00),
-- Order 11 (Customer 11)
(11, 5, 1, 129.99, 0.00),
-- Order 12 (Customer 12)
(12, 11, 1, 34.99, 0.00),
(12, 12, 1, 42.99, 0.00),
(12, 7, 1, 89.99, 0.00),
-- Order 13 (Customer 13)
(13, 22, 1, 199.99, 0.00),
-- Order 14 (Customer 14)
(14, 21, 2, 29.99, 0.00),
(14, 18, 1, 34.99, 0.00),
-- Order 15 (Customer 15)
(15, 2, 1, 299.99, 0.00),
(15, 23, 1, 24.99, 0.00),
-- Order 16 (Customer 1, repeat)
(16, 9, 1, 119.99, 0.00),
(16, 17, 1, 39.99, 0.00),
(16, 20, 1, 64.99, 0.00),
-- Order 17 (Customer 3, repeat)
(17, 16, 1, 159.99, 0.00),
(17, 4, 2, 39.99, 0.00),
(17, 15, 1, 27.99, 0.00),
-- Order 18 (Customer 5, repeat)
(18, 25, 1, 149.99, 0.00),
-- Order 19 (Customer 7, repeat)
(19, 1, 1, 79.99, 0.00),
(19, 3, 2, 49.99, 0.00),
-- Order 20 (Customer 9, repeat)
(20, 2, 1, 299.99, 0.00),
-- Order 21 (Customer 2, repeat)
(21, 8, 1, 59.99, 0.00),
(21, 16, 1, 159.99, 0.00),
(21, 25, 1, 149.99, 0.00),
-- Order 22 (Customer 4, repeat)
(22, 7, 1, 89.99, 0.00),
(22, 21, 1, 29.99, 0.00),
-- Order 23 (Customer 6, repeat)
(23, 2, 1, 299.99, 0.00),
(23, 22, 1, 199.99, 0.00),
-- Order 24 (Customer 8, repeat)
(24, 1, 2, 79.99, 0.00),
-- Order 25 (Customer 10, repeat)
(25, 10, 2, 44.99, 0.00),
(25, 13, 3, 29.99, 0.00),
(25, 19, 2, 49.99, 0.00),
-- Order 26 (Customer 12)
(26, 7, 1, 89.99, 0.00),
-- Order 27 (Customer 14)
(27, 2, 1, 299.99, 0.00),
(27, 6, 1, 24.99, 0.00),
(27, 20, 1, 64.99, 0.00),
-- Order 28 (Customer 15)
(28, 1, 1, 79.99, 0.00),
(28, 5, 1, 129.99, 0.00),
-- Order 29 (Customer 16)
(29, 9, 1, 119.99, 0.00),
-- Order 30 (Customer 18)
(30, 16, 1, 159.99, 0.00),
(30, 8, 1, 59.99, 0.00),
(30, 17, 1, 39.99, 0.00),
(30, 20, 1, 64.99, 0.00);

-- =====================================================
-- Initial Inventory Audit Records
-- Log the initial inventory setup for traceability
-- =====================================================
INSERT INTO Inventory_Audit (product_id, action_type, old_quantity, new_quantity, quantity_change, change_reason, changed_by) VALUES
(1, 'INSERT', NULL, 45, 45, 'Initial inventory setup', 'ADMIN'),
(2, 'INSERT', NULL, 28, 28, 'Initial inventory setup', 'ADMIN'),
(3, 'INSERT', NULL, 67, 67, 'Initial inventory setup', 'ADMIN'),
(4, 'INSERT', NULL, 89, 89, 'Initial inventory setup', 'ADMIN'),
(5, 'INSERT', NULL, 34, 34, 'Initial inventory setup', 'ADMIN'),
(6, 'INSERT', NULL, 120, 120, 'Initial inventory setup', 'ADMIN'),
(7, 'INSERT', NULL, 56, 56, 'Initial inventory setup', 'ADMIN'),
(8, 'INSERT', NULL, 78, 78, 'Initial inventory setup', 'ADMIN'),
(9, 'INSERT', NULL, 42, 42, 'Initial inventory setup', 'ADMIN'),
(10, 'INSERT', NULL, 95, 95, 'Initial inventory setup', 'ADMIN'),
(11, 'INSERT', NULL, 150, 150, 'Initial inventory setup', 'ADMIN'),
(12, 'INSERT', NULL, 88, 88, 'Initial inventory setup', 'ADMIN'),
(13, 'INSERT', NULL, 72, 72, 'Initial inventory setup', 'ADMIN'),
(14, 'INSERT', NULL, 65, 65, 'Initial inventory setup', 'ADMIN'),
(15, 'INSERT', NULL, 110, 110, 'Initial inventory setup', 'ADMIN'),
(16, 'INSERT', NULL, 38, 38, 'Initial inventory setup', 'ADMIN'),
(17, 'INSERT', NULL, 125, 125, 'Initial inventory setup', 'ADMIN'),
(18, 'INSERT', NULL, 92, 92, 'Initial inventory setup', 'ADMIN'),
(19, 'INSERT', NULL, 76, 76, 'Initial inventory setup', 'ADMIN'),
(20, 'INSERT', NULL, 54, 54, 'Initial inventory setup', 'ADMIN'),
(21, 'INSERT', NULL, 105, 105, 'Initial inventory setup', 'ADMIN'),
(22, 'INSERT', NULL, 31, 31, 'Initial inventory setup', 'ADMIN'),
(23, 'INSERT', NULL, 68, 68, 'Initial inventory setup', 'ADMIN'),
(24, 'INSERT', NULL, 143, 143, 'Initial inventory setup', 'ADMIN'),
(25, 'INSERT', NULL, 27, 27, 'Initial inventory setup', 'ADMIN');
