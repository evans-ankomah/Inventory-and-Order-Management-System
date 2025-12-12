USE inventory_management;


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

-- ============================================================================
-- PRODUCTS: 25 products across 5 categories
-- ============================================================================
INSERT INTO Products (product_name, category, price, description) VALUES
-- Electronics (5 products)
('Wireless Bluetooth Headphones', 'Electronics', 79.99, 'Premium noise-canceling over-ear headphones'),
('Smart Watch Pro', 'Electronics', 299.99, 'Fitness tracking smartwatch with GPS'),
('USB-C Hub Adapter', 'Electronics', 49.99, '7-in-1 multiport adapter'),
('Portable Power Bank 20000mAh', 'Electronics', 39.99, 'Fast charging portable battery'),
('4K Webcam', 'Electronics', 129.99, 'High-definition webcam for streaming'),

-- Apparel (5 products)
('Men\'s Cotton T-Shirt', 'Apparel', 24.99, 'Comfortable 100% cotton t-shirt'),
('Women\'s Running Shoes', 'Apparel', 89.99, 'Lightweight athletic shoes'),
('Classic Denim Jeans', 'Apparel', 59.99, 'Premium stretch denim jeans'),
('Winter Hooded Jacket', 'Apparel', 119.99, 'Waterproof insulated jacket'),
('Athletic Yoga Pants', 'Apparel', 44.99, 'High-waist moisture-wicking leggings'),

-- Books (5 products)
('The Art of SQL Mastery', 'Books', 34.99, 'Comprehensive guide to database design'),
('Python Programming Complete', 'Books', 42.99, 'From beginner to advanced Python'),
('Digital Marketing Essentials', 'Books', 29.99, 'Modern marketing strategies'),
('Data Science Handbook', 'Books', 54.99, 'Practical data analysis techniques'),
('Leadership Principles', 'Books', 27.99, 'Building effective teams'),

-- Home & Garden (5 products)
('Stainless Steel Cookware Set', 'Home & Garden', 159.99, '12-piece professional cookware'),
('Memory Foam Pillow', 'Home & Garden', 39.99, 'Ergonomic neck support pillow'),
('LED Desk Lamp', 'Home & Garden', 34.99, 'Adjustable brightness desk lamp'),
('Indoor Plant Collection', 'Home & Garden', 49.99, 'Set of 3 low-maintenance plants'),
('Cotton Bed Sheet Set', 'Home & Garden', 64.99, 'Queen size 400 thread count sheets'),

-- Sports (5 products)
('Yoga Mat with Carry Strap', 'Sports', 29.99, 'Non-slip 6mm thick mat'),
('Adjustable Dumbbells Set', 'Sports', 199.99, '50lb adjustable weight set'),
('Resistance Bands Kit', 'Sports', 24.99, 'Set of 5 resistance levels'),
('Soccer Ball Official Size', 'Sports', 19.99, 'FIFA approved soccer ball'),
('Camping Tent 4-Person', 'Sports', 149.99, 'Waterproof camping tent');

-- ============================================================================
-- INVENTORY: Stock levels for all products
-- ============================================================================
INSERT INTO Inventory (product_id, quantity_on_hand) VALUES
(1, 45), (2, 28), (3, 67), (4, 89), (5, 34),
(6, 120), (7, 56), (8, 78), (9, 42), (10, 95),
(11, 150), (12, 88), (13, 72), (14, 65), (15, 110),
(16, 38), (17, 125), (18, 92), (19, 76), (20, 54),
(21, 105), (22, 31), (23, 68), (24, 143), (25, 27);

-- ============================================================================
-- ORDERS: 30 orders with various statuses
-- ============================================================================
INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
(1, '2024-01-15', 109.98, 'Delivered'),
(2, '2024-01-18', 299.99, 'Delivered'),
(3, '2024-02-05', 154.97, 'Delivered'),
(4, '2024-02-12', 89.99, 'Shipped'),
(5, '2024-02-20', 247.96, 'Delivered'),
(6, '2024-03-03', 79.99, 'Delivered'),
(7, '2024-03-10', 194.97, 'Shipped'),
(8, '2024-03-15', 329.98, 'Delivered'),
(9, '2024-04-01', 84.98, 'Delivered'),
(10, '2024-04-08', 412.95, 'Delivered'),
(11, '2024-04-22', 129.99, 'Shipped'),
(12, '2024-05-05', 167.97, 'Delivered'),
(13, '2024-05-14', 199.99, 'Delivered'),
(14, '2024-05-28', 94.98, 'Shipped'),
(15, '2024-06-03', 289.97, 'Delivered'),
(1, '2024-06-15', 224.97, 'Delivered'),
(3, '2024-06-22', 314.96, 'Shipped'),
(5, '2024-07-01', 149.99, 'Delivered'),
(7, '2024-07-10', 179.98, 'Delivered'),
(9, '2024-07-18', 254.96, 'Shipped'),
(2, '2024-08-02', 369.97, 'Delivered'),
(4, '2024-08-12', 119.98, 'Delivered'),
(6, '2024-08-25', 449.95, 'Shipped'),
(8, '2024-09-05', 159.98, 'Delivered'),
(10, '2024-09-14', 274.97, 'Delivered'),
(12, '2024-09-28', 89.99, 'Pending'),
(14, '2024-10-08', 384.96, 'Pending'),
(15, '2024-10-15', 209.98, 'Pending'),
(16, '2024-10-22', 139.98, 'Pending'),
(18, '2024-10-30', 324.97, 'Pending');

-- ============================================================================
-- ORDER_ITEMS: Line items for each order (50+ items)
-- ============================================================================
INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase) VALUES
-- Order 1 (Customer 1)
(1, 1, 1, 79.99),
(1, 21, 1, 29.99),
-- Order 2 (Customer 2)
(2, 2, 1, 299.99),
-- Order 3 (Customer 3)
(3, 6, 2, 24.99),
(3, 11, 1, 34.99),
(3, 13, 2, 29.99),
-- Order 4 (Customer 4)
(4, 7, 1, 89.99),
-- Order 5 (Customer 5)
(5, 3, 2, 49.99),
(5, 12, 1, 42.99),
(5, 17, 2, 39.99),
-- Order 6 (Customer 6)
(6, 1, 1, 79.99),
-- Order 7 (Customer 7)
(7, 16, 1, 159.99),
(7, 18, 1, 34.99),
-- Order 8 (Customer 8)
(8, 2, 1, 299.99),
(8, 21, 1, 29.99),
-- Order 9 (Customer 9)
(9, 24, 2, 19.99),
(9, 6, 1, 24.99),
(9, 19, 1, 49.99),
-- Order 10 (Customer 10)
(10, 8, 2, 59.99),
(10, 10, 1, 44.99),
(10, 14, 1, 54.99),
(10, 22, 1, 199.99),
-- Order 11 (Customer 11)
(11, 5, 1, 129.99),
-- Order 12 (Customer 12)
(12, 11, 1, 34.99),
(12, 12, 1, 42.99),
(12, 7, 1, 89.99),
-- Order 13 (Customer 13)
(13, 22, 1, 199.99),
-- Order 14 (Customer 14)
(14, 21, 2, 29.99),
(14, 18, 1, 34.99),
-- Order 15 (Customer 15)
(15, 2, 1, 299.99),
(15, 23, 1, 24.99),
-- Order 16 (Customer 1, repeat)
(16, 9, 1, 119.99),
(16, 17, 1, 39.99),
(16, 20, 1, 64.99),
-- Order 17 (Customer 3, repeat)
(17, 16, 1, 159.99),
(17, 4, 2, 39.99),
(17, 15, 1, 27.99),
-- Order 18 (Customer 5, repeat)
(18, 25, 1, 149.99),
-- Order 19 (Customer 7, repeat)
(19, 1, 1, 79.99),
(19, 3, 2, 49.99),
-- Order 20 (Customer 9, repeat)
(20, 2, 1, 299.99),
(20, 6, 2, 24.99),
-- Order 21 (Customer 2, repeat)
(21, 8, 1, 59.99),
(21, 16, 1, 159.99),
(21, 25, 1, 149.99),
-- Order 22 (Customer 4, repeat)
(22, 7, 1, 89.99),
(22, 21, 1, 29.99),
-- Order 23 (Customer 6, repeat)
(23, 2, 1, 299.99),
(23, 22, 1, 199.99),
(23, 4, 1, 39.99),
-- Order 24 (Customer 8, repeat)
(24, 1, 2, 79.99),
-- Order 25 (Customer 10, repeat)
(25, 10, 2, 44.99),
(25, 13, 3, 29.99),
(25, 19, 2, 49.99),
-- Order 26 (Customer 12)
(26, 7, 1, 89.99),
-- Order 27 (Customer 14)
(27, 2, 1, 299.99),
(27, 6, 1, 24.99),
(27, 20, 1, 64.99),
-- Order 28 (Customer 15)
(28, 1, 1, 79.99),
(28, 5, 1, 129.99),
-- Order 29 (Customer 16)
(29, 9, 1, 119.99),
(29, 19, 1, 49.99),
-- Order 30 (Customer 18)
(30, 16, 1, 159.99),
(30, 8, 1, 59.99),
(30, 17, 1, 39.99),
(30, 20, 1, 64.99);

-- ============================================================================
-- DATA SUMMARY
-- ============================================================================
-- Total Customers: 20
-- Total Products: 25 (5 per category)
-- Total Inventory Records: 25
-- Total Orders: 30
-- Total Order Items: 67
-- Order Status Distribution:
--   - Delivered: 20 orders
--   - Shipped: 5 orders
--   - Pending: 5 orders
-- ============================================================================
