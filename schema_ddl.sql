
-- =====================================================
-- Inventory and Order Management System - Schema (DDL)
-- =====================================================
-- Beginner-friendly version with core SQL concepts:
-- - PRIMARY KEY and FOREIGN KEY constraints
-- - NOT NULL and CHECK constraints
-- - Basic data types: INT, VARCHAR, DECIMAL, DATE
-- =====================================================

-- Create database
DROP DATABASE IF EXISTS inventory_management;
CREATE DATABASE inventory_management;
USE inventory_management;

-- Table 1: Customers
-- Stores customer information
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    shipping_address TEXT NOT NULL
);

-- Table 2: Products
-- Stores product catalog
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    CONSTRAINT chk_price CHECK (price >= 0)
);

-- Table 3: Inventory
-- Tracks stock level for each product (one-to-one with Products)
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_quantity CHECK (quantity_on_hand >= 0),
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Table 4: Orders
-- Stores customer orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Table 5: Order_Items
-- Bridge table: links multiple products to each order (many-to-many)
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (price_at_purchase >= 0),
    CONSTRAINT fk_order_items_order 
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT fk_order_items_product 
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

