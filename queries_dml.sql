USE inventory_management;

-- =====================================================
-- Inventory and Order Management System - Queries (DML)
-- =====================================================
-- Enterprise-level queries including:
-- - Business KPIs and analytics
-- - Window functions for advanced analysis
-- - Comprehensive views for reporting
-- - Triggers for automatic audit logging
-- - Enhanced stored procedures with audit integration
-- =====================================================

-- =====================================================
-- SECTION 1: TRIGGERS FOR AUDIT LOGGING
-- =====================================================
-- These triggers automatically log all inventory changes
-- to the Inventory_Audit table for complete traceability

DELIMITER //

-- Trigger: Log inventory inserts
CREATE TRIGGER trg_inventory_audit_insert
AFTER INSERT ON Inventory
FOR EACH ROW
BEGIN
    INSERT INTO Inventory_Audit (
        product_id, action_type, old_quantity, new_quantity, 
        quantity_change, change_reason, changed_by
    ) VALUES (
        NEW.product_id, 'INSERT', NULL, NEW.quantity_on_hand, 
        NEW.quantity_on_hand, 'New inventory record created', 'SYSTEM'
    );
END //

-- Trigger: Log inventory updates
CREATE TRIGGER trg_inventory_audit_update
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    -- Only log if quantity actually changed
    IF OLD.quantity_on_hand <> NEW.quantity_on_hand THEN
        INSERT INTO Inventory_Audit (
            product_id, action_type, old_quantity, new_quantity, 
            quantity_change, change_reason, changed_by
        ) VALUES (
            NEW.product_id, 'UPDATE', OLD.quantity_on_hand, NEW.quantity_on_hand, 
            NEW.quantity_on_hand - OLD.quantity_on_hand, 'Inventory adjustment', 'SYSTEM'
        );
    END IF;
END //

-- Trigger: Log inventory deletes
CREATE TRIGGER trg_inventory_audit_delete
BEFORE DELETE ON Inventory
FOR EACH ROW
BEGIN
    INSERT INTO Inventory_Audit (
        product_id, action_type, old_quantity, new_quantity, 
        quantity_change, change_reason, changed_by
    ) VALUES (
        OLD.product_id, 'DELETE', OLD.quantity_on_hand, NULL, 
        -OLD.quantity_on_hand, 'Inventory record deleted', 'SYSTEM'
    );
END //

DELIMITER ;

-- =====================================================
-- SECTION 2: BUSINESS KPI QUERIES
-- =====================================================

-- KPI 1: Total Revenue (Shipped and Delivered Orders Only)
-- Description: Calculate total revenue from completed orders
SELECT 
    SUM(total_amount) AS total_revenue,
    COUNT(*) AS completed_orders,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered');

-- =====================================================
-- KPI 2: Top 10 Customers by Total Spending
-- Description: Identify highest-value customers
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY total_spent DESC
LIMIT 10;

-- =====================================================
-- KPI 3: Top 5 Best-Selling Products by Quantity Sold
-- Description: Most popular products by units sold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price AS current_price,
    SUM(oi.quantity) AS total_quantity_sold,
    COUNT(DISTINCT oi.order_id) AS number_of_orders,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    ROUND(AVG(oi.price_at_purchase), 2) AS avg_selling_price
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- =====================================================
-- KPI 4: Monthly Sales Trend
-- Description: Revenue breakdown by month to identify trends
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(CASE WHEN order_status IN ('Shipped', 'Delivered') THEN total_amount ELSE 0 END) AS completed_revenue,
    SUM(CASE WHEN order_status = 'Pending' THEN total_amount ELSE 0 END) AS pending_revenue
FROM Orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- =====================================================
-- SECTION 3: ANALYTICAL QUERIES WITH WINDOW FUNCTIONS
-- =====================================================

-- ANALYTICAL QUERY 1: Sales Rank by Category
-- Description: Rank products within each category by total sales revenue
SELECT 
    category,
    product_id,
    product_name,
    current_price,
    total_revenue,
    units_sold,
    category_rank,
    ROUND((total_revenue / category_total_revenue) * 100, 2) AS pct_of_category_revenue
FROM (
    SELECT 
        p.category,
        p.product_id,
        p.product_name,
        p.price AS current_price,
        SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
        SUM(oi.quantity) AS units_sold,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.price_at_purchase) DESC) AS category_rank,
        SUM(SUM(oi.quantity * oi.price_at_purchase)) OVER (PARTITION BY p.category) AS category_total_revenue
    FROM Products p
    INNER JOIN Order_Items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_id, p.product_name, p.price
) ranked_products
ORDER BY category, category_rank;

-- =====================================================
-- ANALYTICAL QUERY 2: Customer Order Frequency
-- Description: Show order history with previous order date for each customer
SELECT 
    c.customer_id,
    c.full_name,
    o.order_id,
    o.order_date AS current_order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date,
    DATEDIFF(
        o.order_date, 
        LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)
    ) AS days_since_last_order,
    o.total_amount AS current_order_amount,
    LAG(o.total_amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_amount,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS order_sequence,
    SUM(o.total_amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS cumulative_spending
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- =====================================================
-- ANALYTICAL QUERY 3: Running Total and Moving Average
-- Description: Calculate running totals and 3-month moving average
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(total_amount) AS monthly_revenue,
    SUM(SUM(total_amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS running_total,
    ROUND(AVG(SUM(total_amount)) OVER (
        ORDER BY YEAR(order_date), MONTH(order_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3_months
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered')
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- =====================================================
-- SECTION 4: VIEWS FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- VIEW 1: CustomerSalesSummary
-- Description: Pre-calculated customer spending metrics for fast analytics
CREATE OR REPLACE VIEW CustomerSalesSummary AS
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.shipping_address,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_amount_spent,
    COALESCE(ROUND(AVG(o.total_amount), 2), 0) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    MIN(o.order_date) AS first_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'No Orders'
        WHEN COUNT(o.order_id) >= 5 THEN 'VIP'
        WHEN COUNT(o.order_id) >= 3 THEN 'Loyal'
        WHEN COUNT(o.order_id) = 1 THEN 'New'
        ELSE 'Active'
    END AS customer_status,
    c.created_at AS customer_since
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email, c.phone, c.shipping_address, c.created_at;

-- =====================================================
-- VIEW 2: InventoryAuditSummary
-- Description: Track all inventory changes with product context
CREATE OR REPLACE VIEW InventoryAuditSummary AS
SELECT 
    ia.audit_id,
    p.product_id,
    p.product_name,
    p.category,
    ia.action_type,
    ia.old_quantity,
    ia.new_quantity,
    ia.quantity_change,
    ia.change_reason,
    ia.changed_by,
    ia.changed_at,
    ia.related_order_id,
    CASE 
        WHEN ia.quantity_change > 0 THEN 'INCREASE'
        WHEN ia.quantity_change < 0 THEN 'DECREASE'
        ELSE 'NO_CHANGE'
    END AS change_direction
FROM Inventory_Audit ia
JOIN Products p ON ia.product_id = p.product_id
ORDER BY ia.changed_at DESC;

-- =====================================================
-- VIEW 3: ProductInventoryStatus
-- Description: Complete product and stock overview with status indicators
CREATE OR REPLACE VIEW ProductInventoryStatus AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.is_active,
    i.quantity_on_hand,
    i.reorder_level,
    i.last_restock_date,
    CASE 
        WHEN i.quantity_on_hand = 0 THEN 'OUT_OF_STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level THEN 'CRITICAL'
        WHEN i.quantity_on_hand <= i.reorder_level * 2 THEN 'LOW'
        ELSE 'ADEQUATE'
    END AS stock_status,
    ROUND(p.price * i.quantity_on_hand, 2) AS inventory_value,
    DATEDIFF(CURDATE(), i.last_restock_date) AS days_since_restock
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id;

-- =====================================================
-- VIEW 4: OrderDetailsSummary
-- Description: Complete order with items breakdown
CREATE OR REPLACE VIEW OrderDetailsSummary AS
SELECT 
    o.order_id,
    c.customer_id,
    c.full_name AS customer_name,
    c.email AS customer_email,
    o.order_date,
    o.order_status,
    o.total_amount,
    o.shipping_date,
    o.delivery_date,
    COUNT(oi.order_item_id) AS total_line_items,
    COALESCE(SUM(oi.quantity), 0) AS total_units,
    DATEDIFF(o.shipping_date, o.order_date) AS processing_days,
    DATEDIFF(o.delivery_date, o.shipping_date) AS shipping_days,
    o.created_at,
    o.updated_at
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
LEFT JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_id, c.full_name, c.email, o.order_date, 
         o.order_status, o.total_amount, o.shipping_date, o.delivery_date,
         o.created_at, o.updated_at;

-- =====================================================
-- VIEW 5: MonthlySalesReport
-- Description: Aggregated monthly metrics for management reporting
CREATE OR REPLACE VIEW MonthlySalesReport AS
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DATE_FORMAT(order_date, '%Y-%m') AS period,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    SUM(CASE WHEN order_status = 'Delivered' THEN total_amount ELSE 0 END) AS delivered_revenue,
    SUM(CASE WHEN order_status = 'Shipped' THEN total_amount ELSE 0 END) AS shipped_revenue,
    SUM(CASE WHEN order_status = 'Pending' THEN total_amount ELSE 0 END) AS pending_revenue,
    COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) AS cancelled_orders
FROM Orders
GROUP BY YEAR(order_date), MONTH(order_date), DATE_FORMAT(order_date, '%Y-%m');

-- =====================================================
-- VIEW 6: CategoryPerformance
-- Description: Sales metrics by product category
CREATE OR REPLACE VIEW CategoryPerformance AS
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.quantity * oi.price_at_purchase), 0) AS total_revenue,
    COALESCE(ROUND(AVG(oi.price_at_purchase), 2), 0) AS avg_selling_price,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COALESCE(ROUND(SUM(oi.quantity * oi.price_at_purchase) / NULLIF(COUNT(DISTINCT oi.order_id), 0), 2), 0) AS revenue_per_order
FROM Products p
LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- =====================================================
-- VIEW 7: LowStockAlert
-- Description: Products needing reorder with sales velocity
CREATE OR REPLACE VIEW LowStockAlert AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    i.quantity_on_hand,
    i.reorder_level,
    CASE 
        WHEN i.quantity_on_hand = 0 THEN 'CRITICAL - OUT OF STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level THEN 'URGENT - BELOW REORDER LEVEL'
        WHEN i.quantity_on_hand <= i.reorder_level * 1.5 THEN 'WARNING - APPROACHING REORDER'
        ELSE 'OK'
    END AS alert_level,
    COALESCE(recent_sales.qty_sold_30_days, 0) AS qty_sold_30_days,
    i.last_restock_date,
    DATEDIFF(CURDATE(), i.last_restock_date) AS days_since_restock
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id
LEFT JOIN (
    SELECT oi.product_id, SUM(oi.quantity) AS qty_sold_30_days
    FROM Order_Items oi
    JOIN Orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY oi.product_id
) recent_sales ON p.product_id = recent_sales.product_id
WHERE i.quantity_on_hand <= i.reorder_level * 1.5
ORDER BY i.quantity_on_hand ASC;

-- =====================================================
-- SECTION 5: STORED PROCEDURE WITH AUDIT LOGGING
-- =====================================================

DELIMITER //

-- Enhanced ProcessNewOrder Stored Procedure
-- Now includes audit logging for full traceability
CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT, 
    IN p_product_id INT, 
    IN p_quantity INT,
    IN p_changed_by VARCHAR(100)
)
proc_main: BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_product_price DECIMAL(10,2);
    DECLARE v_order_id INT;
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_product_name VARCHAR(150);
    DECLARE v_customer_name VARCHAR(100);
    
    -- Declare exit handler for errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 
            'ERROR' AS status,
            'Transaction failed. Order could not be processed. Please try again.' AS message;
    END;
    
    -- Set default changed_by if null
    IF p_changed_by IS NULL THEN
        SET p_changed_by = 'SYSTEM';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Step 1: Validate customer exists
    SELECT full_name INTO v_customer_name 
    FROM Customers WHERE customer_id = p_customer_id;
    
    IF v_customer_name IS NULL THEN
        ROLLBACK;
        SELECT 
            'ERROR' AS status,
            CONCAT('Customer ID ', p_customer_id, ' does not exist.') AS message;
        LEAVE proc_main;
    END IF;
    
    -- Step 2: Validate product exists and is active
    SELECT product_name, price INTO v_product_name, v_product_price
    FROM Products 
    WHERE product_id = p_product_id AND is_active = TRUE;
    
    IF v_product_name IS NULL THEN
        ROLLBACK;
        SELECT 
            'ERROR' AS status,
            CONCAT('Product ID ', p_product_id, ' does not exist or is inactive.') AS message;
        LEAVE proc_main;
    END IF;
    
    -- Step 3: Validate quantity is positive
    IF p_quantity <= 0 THEN
        ROLLBACK;
        SELECT 
            'ERROR' AS status,
            'Quantity must be greater than 0.' AS message;
        LEAVE proc_main;
    END IF;
    
    -- Step 4: Get current inventory level (with row lock)
    SELECT quantity_on_hand INTO v_current_stock
    FROM Inventory 
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Step 5: Check if sufficient stock is available
    IF v_current_stock < p_quantity THEN
        ROLLBACK;
        SELECT 
            'ERROR' AS status,
            CONCAT('Insufficient inventory. Available: ', v_current_stock, ', Requested: ', p_quantity) AS message;
        LEAVE proc_main;
    END IF;
    
    -- Step 6: Calculate total amount
    SET v_total_amount = v_product_price * p_quantity;
    
    -- Step 7: Create new order
    INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
    VALUES (p_customer_id, CURDATE(), v_total_amount, 'Pending');
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- Step 8: Create order item
    INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase)
    VALUES (v_order_id, p_product_id, p_quantity, v_product_price);
    
    -- Step 9: Update inventory (reduce stock)
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand - p_quantity
    WHERE product_id = p_product_id;
    
    -- Step 10: Log to audit table with order reference
    INSERT INTO Inventory_Audit (
        product_id, action_type, old_quantity, new_quantity, quantity_change,
        change_reason, changed_by, related_order_id
    ) VALUES (
        p_product_id, 'ORDER', v_current_stock, v_current_stock - p_quantity, -p_quantity,
        CONCAT('Order fulfillment - Order #', v_order_id), p_changed_by, v_order_id
    );
    
    -- Step 11: Commit transaction
    COMMIT;
    
    -- Step 12: Return success message with details
    SELECT 
        'SUCCESS' AS status,
        'Order processed successfully!' AS message,
        v_order_id AS order_id,
        v_customer_name AS customer_name,
        v_product_name AS product_name,
        p_quantity AS quantity_ordered,
        v_product_price AS unit_price,
        v_total_amount AS total_amount,
        (v_current_stock - p_quantity) AS remaining_stock;
        
END //

-- =====================================================
-- Stored Procedure: RestockInventory
-- Adds stock and logs the restock action
-- =====================================================
CREATE PROCEDURE RestockInventory(
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_changed_by VARCHAR(100)
)
proc_main: BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_product_name VARCHAR(150);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR' AS status, 'Restock failed. Please try again.' AS message;
    END;
    
    IF p_changed_by IS NULL THEN
        SET p_changed_by = 'SYSTEM';
    END IF;
    
    START TRANSACTION;
    
    -- Validate product
    SELECT p.product_name, i.quantity_on_hand 
    INTO v_product_name, v_current_stock
    FROM Products p
    JOIN Inventory i ON p.product_id = i.product_id
    WHERE p.product_id = p_product_id;
    
    IF v_product_name IS NULL THEN
        ROLLBACK;
        SELECT 'ERROR' AS status, CONCAT('Product ID ', p_product_id, ' not found.') AS message;
        LEAVE proc_main;
    END IF;
    
    IF p_quantity <= 0 THEN
        ROLLBACK;
        SELECT 'ERROR' AS status, 'Quantity must be greater than 0.' AS message;
        LEAVE proc_main;
    END IF;
    
    -- Update inventory
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand + p_quantity,
        last_restock_date = CURDATE()
    WHERE product_id = p_product_id;
    
    -- Log to audit
    INSERT INTO Inventory_Audit (
        product_id, action_type, old_quantity, new_quantity, quantity_change,
        change_reason, changed_by
    ) VALUES (
        p_product_id, 'RESTOCK', v_current_stock, v_current_stock + p_quantity, p_quantity,
        'Inventory restock', p_changed_by
    );
    
    COMMIT;
    
    SELECT 
        'SUCCESS' AS status,
        'Inventory restocked successfully!' AS message,
        v_product_name AS product_name,
        v_current_stock AS previous_stock,
        (v_current_stock + p_quantity) AS new_stock,
        p_quantity AS quantity_added;
        
END //

DELIMITER ;

-- =====================================================
-- SECTION 6: ADDITIONAL USEFUL QUERIES
-- =====================================================

-- Low Stock Alert: Products with inventory below threshold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    i.quantity_on_hand,
    i.reorder_level,
    CASE 
        WHEN i.quantity_on_hand = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_on_hand <= i.reorder_level THEN 'CRITICAL'
        WHEN i.quantity_on_hand < i.reorder_level * 2 THEN 'LOW STOCK'
        ELSE 'ADEQUATE'
    END AS stock_status
FROM Products p
INNER JOIN Inventory i ON p.product_id = i.product_id
WHERE i.quantity_on_hand <= i.reorder_level * 2
ORDER BY i.quantity_on_hand ASC;

-- =====================================================
-- Customer Lifetime Value (CLV) Analysis
SELECT 
    customer_id,
    full_name,
    email,
    total_orders,
    total_amount_spent,
    avg_order_value,
    customer_status,
    days_since_last_order,
    CASE 
        WHEN total_amount_spent >= 500 THEN 'VIP'
        WHEN total_amount_spent >= 300 THEN 'Premium'
        WHEN total_amount_spent >= 100 THEN 'Standard'
        ELSE 'New'
    END AS customer_tier,
    CASE 
        WHEN days_since_last_order <= 30 THEN 'Active'
        WHEN days_since_last_order <= 90 THEN 'At Risk'
        WHEN days_since_last_order <= 180 THEN 'Lapsing'
        ELSE 'Churned'
    END AS engagement_status
FROM CustomerSalesSummary
ORDER BY total_amount_spent DESC;

-- =====================================================
-- Inventory Turnover Analysis
SELECT 
    p.category,
    p.product_name,
    i.quantity_on_hand AS current_stock,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    ROUND(COALESCE(SUM(oi.quantity), 0) / NULLIF(i.quantity_on_hand, 0), 2) AS turnover_ratio,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) / NULLIF(i.quantity_on_hand, 0) > 2 THEN 'Fast Moving'
        WHEN COALESCE(SUM(oi.quantity), 0) / NULLIF(i.quantity_on_hand, 0) > 0.5 THEN 'Normal'
        ELSE 'Slow Moving'
    END AS movement_status
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id
LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.category, p.product_name, i.quantity_on_hand
ORDER BY turnover_ratio DESC;

-- =====================================================
-- EXAMPLE USAGE
-- =====================================================

-- Example 1: Process a new order
-- CALL ProcessNewOrder(1, 3, 2, 'SALES_REP');

-- Example 2: Restock inventory
-- CALL RestockInventory(5, 50, 'WAREHOUSE_MGR');

-- Example 3: View audit log for a product
-- SELECT * FROM InventoryAuditSummary WHERE product_id = 3 ORDER BY changed_at DESC;

-- Example 4: Check low stock alerts
-- SELECT * FROM LowStockAlert;

-- Example 5: View monthly sales report
-- SELECT * FROM MonthlySalesReport ORDER BY year DESC, month DESC;