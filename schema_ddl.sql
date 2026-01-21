-- =====================================================
-- Inventory and Order Management System - Schema (DDL)
-- =====================================================
-- Enterprise-level schema with full data integrity:
-- - PRIMARY KEY and FOREIGN KEY constraints with ON DELETE/UPDATE rules
-- - NOT NULL, UNIQUE, and CHECK constraints
-- - Audit table for inventory change tracking
-- - Timestamps for traceability (created_at, updated_at)
-- - Performance indexes for query optimization
-- =====================================================

-- Create database
DROP DATABASE IF EXISTS inventory_management;
CREATE DATABASE inventory_management;
USE inventory_management;

-- =====================================================
-- Table 1: Customers
-- Stores customer information with unique email enforcement
-- =====================================================
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@_%.__%')
);

-- =====================================================
-- Table 2: Products
-- Stores product catalog with unique product names
-- =====================================================
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_category CHECK (category IN ('Electronics', 'Apparel', 'Books', 'Home & Garden', 'Sports'))
);

-- =====================================================
-- Table 3: Inventory
-- Tracks stock level for each product (one-to-one with Products)
-- ON DELETE CASCADE: If product is deleted, inventory record is also deleted
-- ON UPDATE CASCADE: If product_id changes, inventory record is updated
-- =====================================================
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 20,
    last_restock_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_quantity CHECK (quantity_on_hand >= 0),
    CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0),
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Table 4: Orders
-- Stores customer orders with status validation
-- ON DELETE RESTRICT: Cannot delete customer with existing orders
-- ON UPDATE CASCADE: If customer_id changes, orders are updated
-- =====================================================
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    shipping_date DATE,
    delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_order_status CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =====================================================
-- Table 5: Order_Items
-- Bridge table: links multiple products to each order (many-to-many)
-- ON DELETE CASCADE for order: If order is deleted, items are also deleted
-- ON DELETE RESTRICT for product: Cannot delete product that has been ordered
-- =====================================================
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (price_at_purchase >= 0),
    CONSTRAINT chk_discount CHECK (discount_amount >= 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_order_items_order 
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_product 
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =====================================================
-- Table 6: Inventory_Audit
-- Audit table for tracking all inventory changes
-- Provides full traceability for enterprise compliance
-- =====================================================
CREATE TABLE Inventory_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE', 'ORDER', 'RESTOCK', 'ADJUSTMENT') NOT NULL,
    old_quantity INT,
    new_quantity INT,
    quantity_change INT,
    change_reason VARCHAR(255),
    changed_by VARCHAR(100) DEFAULT 'SYSTEM',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    related_order_id INT,
    ip_address VARCHAR(45),
    CONSTRAINT fk_audit_product 
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_audit_order 
        FOREIGN KEY (related_order_id) REFERENCES Orders(order_id)
        ON DELETE SET NULL
);

-- =====================================================
-- Performance Indexes
-- Improve query performance for common operations
-- =====================================================

-- Customer queries
CREATE INDEX idx_customers_email ON Customers(email);
CREATE INDEX idx_customers_name ON Customers(full_name);

-- Product queries
CREATE INDEX idx_products_category ON Products(category);
CREATE INDEX idx_products_name ON Products(product_name);
CREATE INDEX idx_products_active ON Products(is_active);

-- Order queries
CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_orders_date ON Orders(order_date);
CREATE INDEX idx_orders_status ON Orders(order_status);
CREATE INDEX idx_orders_date_status ON Orders(order_date, order_status);

-- Order items queries
CREATE INDEX idx_order_items_order ON Order_Items(order_id);
CREATE INDEX idx_order_items_product ON Order_Items(product_id);

-- Inventory queries
CREATE INDEX idx_inventory_product ON Inventory(product_id);
CREATE INDEX idx_inventory_quantity ON Inventory(quantity_on_hand);

-- Audit queries
CREATE INDEX idx_audit_product ON Inventory_Audit(product_id);
CREATE INDEX idx_audit_timestamp ON Inventory_Audit(changed_at);
CREATE INDEX idx_audit_action ON Inventory_Audit(action_type);
CREATE INDEX idx_audit_order ON Inventory_Audit(related_order_id);
