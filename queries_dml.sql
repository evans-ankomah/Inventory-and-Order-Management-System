
USE inventory_management;

-- ============================================================================
-- SECTION 1: BUSINESS KPI QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- KPI 1: Total Revenue (Shipped and Delivered Orders Only)
-- Description: Calculate total revenue from completed orders
-- ----------------------------------------------------------------------------
SELECT 
    SUM(total_amount) AS total_revenue,
    COUNT(*) AS completed_orders
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered');

-- ----------------------------------------------------------------------------
-- KPI 2: Top 10 Customers by Total Spending
-- Description: Identify highest-value customers
-- ----------------------------------------------------------------------------
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY total_spent DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- KPI 3: Top 5 Best-Selling Products by Quantity Sold
-- Description: Most popular products by units sold
-- ----------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price AS current_price,
    SUM(oi.quantity) AS total_quantity_sold,
    COUNT(DISTINCT oi.order_id) AS number_of_orders,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- KPI 4: Monthly Sales Trend
-- Description: Revenue breakdown by month to identify trends
-- ----------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS month_name,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    SUM(CASE WHEN order_status IN ('Shipped', 'Delivered') THEN total_amount ELSE 0 END) AS completed_revenue
FROM Orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), YEAR(order_date), MONTHNAME(order_date)
ORDER BY month;

-- ============================================================================
-- SECTION 2: ANALYTICAL QUERIES WITH WINDOW FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ANALYTICAL QUERY 1: Sales Rank by Category
-- Description: Rank products within each category by total sales revenue
-- ----------------------------------------------------------------------------
SELECT 
    category,
    product_id,
    product_name,
    current_price,
    total_revenue,
    units_sold,
    category_rank,
    -- Show percentage of category revenue
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

-- ----------------------------------------------------------------------------
-- ANALYTICAL QUERY 2: Customer Order Frequency
-- Description: Show current order date alongside previous order date
--              to analyze customer return patterns
-- ----------------------------------------------------------------------------
SELECT 
    c.customer_id,
    c.full_name,
    o.order_id,
    o.order_date AS current_order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date,
    -- Calculate days between orders
    DATEDIFF(
        o.order_date, 
        LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date)
    ) AS days_since_last_order,
    o.total_amount AS current_order_amount,
    LAG(o.total_amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_amount,
    -- Show order sequence number for each customer
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS order_sequence
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- ============================================================================
-- SECTION 3: PERFORMANCE OPTIMIZATION - VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW: CustomerSalesSummary
-- Description: Pre-calculated customer spending metrics for fast analytics
-- ----------------------------------------------------------------------------
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
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifetime_days,
    -- Customer status
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'No Orders'
        WHEN DATEDIFF(CURRENT_DATE, MAX(o.order_date)) > 180 THEN 'Inactive'
        WHEN COUNT(o.order_id) >= 3 THEN 'Loyal'
        WHEN COUNT(o.order_id) = 1 THEN 'New'
        ELSE 'Active'
    END AS customer_status
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email, c.phone, c.shipping_address;

-- Example query using the view:
-- SELECT * FROM CustomerSalesSummary WHERE customer_status = 'Loyal' ORDER BY total_amount_spent DESC;

-- ============================================================================
-- SECTION 4: PERFORMANCE OPTIMIZATION - STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STORED PROCEDURE: ProcessNewOrder
-- Description: Process a new order with inventory management and transactions
-- Parameters:
--   - p_customer_id: The customer placing the order
--   - p_product_id: The product being ordered
--   - p_quantity: Quantity to order
-- Returns: Success message or error
-- ----------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_product_price DECIMAL(10,2);
    DECLARE v_order_id INT;
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_error_msg VARCHAR(255);
    
    -- Declare exit handler for any errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction on error
        ROLLBACK;
        SELECT 'Error: Transaction failed. Order could not be processed.' AS error_message;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE customer_id = p_customer_id) THEN
        SET v_error_msg = CONCAT('Error: Customer ID ', p_customer_id, ' does not exist.');
        ROLLBACK;
        SELECT v_error_msg AS error_message;
        LEAVE BEGIN;
    END IF;
    
    -- Validate product exists
    IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = p_product_id) THEN
        SET v_error_msg = CONCAT('Error: Product ID ', p_product_id, ' does not exist.');
        ROLLBACK;
        SELECT v_error_msg AS error_message;
        LEAVE BEGIN;
    END IF;
    
    -- Validate quantity is positive
    IF p_quantity <= 0 THEN
        ROLLBACK;
        SELECT 'Error: Quantity must be greater than 0.' AS error_message;
        LEAVE BEGIN;
    END IF;
    
    -- Get current inventory level and product price
    SELECT i.quantity_on_hand, p.price
    INTO v_current_stock, v_product_price
    FROM Inventory i
    INNER JOIN Products p ON i.product_id = p.product_id
    WHERE i.product_id = p_product_id
    FOR UPDATE; -- Lock the row for update
    
    -- Check if sufficient stock is available
    IF v_current_stock < p_quantity THEN
        SET v_error_msg = CONCAT(
            'Error: Insufficient inventory. Available: ', 
            v_current_stock, 
            ', Requested: ', 
            p_quantity
        );
        ROLLBACK;
        SELECT v_error_msg AS error_message;
        LEAVE BEGIN;
    END IF;
    
    -- Calculate total amount
    SET v_total_amount = v_product_price * p_quantity;
    
    -- Create new order
    INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
    VALUES (p_customer_id, CURRENT_DATE, v_total_amount, 'Pending');
    
    -- Get the new order ID
    SET v_order_id = LAST_INSERT_ID();
    
    -- Create order item
    INSERT INTO Order_Items (order_id, product_id, quantity, price_at_purchase)
    VALUES (v_order_id, p_product_id, p_quantity, v_product_price);
    
    -- Update inventory (reduce stock)
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand - p_quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id;
    
    -- Commit transaction
    COMMIT;
    
    -- Return success message
    SELECT 
        'Success' AS status,
        v_order_id AS order_id,
        p_customer_id AS customer_id,
        p_product_id AS product_id,
        p_quantity AS quantity_ordered,
        v_product_price AS unit_price,
        v_total_amount AS total_amount,
        (v_current_stock - p_quantity) AS remaining_stock,
        'Order processed successfully!' AS message;
        
END //

DELIMITER ;

-- ============================================================================
-- EXAMPLE USAGE OF STORED PROCEDURE
-- ============================================================================

-- Example 1: Successful order (sufficient inventory)
-- CALL ProcessNewOrder(1, 5, 2);

-- Example 2: Failed order (insufficient inventory)
-- CALL ProcessNewOrder(1, 5, 1000);

-- Example 3: Failed order (invalid customer)
-- CALL ProcessNewOrder(9999, 5, 1);

-- ============================================================================
-- ADDITIONAL USEFUL QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Low Stock Alert: Products with inventory below threshold
-- ----------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    i.quantity_on_hand,
    CASE 
        WHEN i.quantity_on_hand = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_on_hand < 30 THEN 'LOW STOCK'
        WHEN i.quantity_on_hand < 50 THEN 'REORDER SOON'
        ELSE 'ADEQUATE'
    END AS stock_status
FROM Products p
INNER JOIN Inventory i ON p.product_id = i.product_id
WHERE i.quantity_on_hand < 50
ORDER BY i.quantity_on_hand ASC;

-- ----------------------------------------------------------------------------
-- Category Performance Summary
-- ----------------------------------------------------------------------------
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    ROUND(AVG(oi.price_at_purchase), 2) AS avg_price,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------
-- Customer Lifetime Value (CLV) Analysis
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    full_name,
    email,
    total_orders,
    total_amount_spent,
    avg_order_value,
    customer_status,
    CASE 
        WHEN total_amount_spent >= 500 THEN 'VIP'
        WHEN total_amount_spent >= 300 THEN 'Premium'
        WHEN total_amount_spent >= 100 THEN 'Standard'
        ELSE 'New'
    END AS customer_tier
FROM CustomerSalesSummary
ORDER BY total_amount_spent DESC;

-- ============================================================================
-- END OF QUERIES SCRIPT
-- ============================================================================
