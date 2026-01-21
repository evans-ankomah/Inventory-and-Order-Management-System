# Inventory and Order Management System

A production-ready, enterprise-level relational database for e-commerce inventory and order management. This project demonstrates advanced SQL skills including normalized database design (3NF), comprehensive data integrity constraints, audit logging, and performance optimization.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [Installation](#installation)
- [Usage](#usage)
- [Views](#views)
- [Stored Procedures](#stored-procedures)
- [Audit System](#audit-system)
- [Sample Queries](#sample-queries)
- [Project Structure](#project-structure)

---

## Project Overview

This capstone project implements a complete database solution for an e-commerce company's inventory and order management system. It covers the full database lifecycle from design to implementation to analytics.

### Key Objectives

- **Database Design**: Normalized 3NF relational schema with ERD
- **Data Integrity**: Comprehensive constraints (PK, FK, UNIQUE, CHECK, NOT NULL)
- **Audit Logging**: Full traceability of all inventory changes
- **Performance**: Optimized with indexes and pre-calculated views
- **Analytics**: Business KPIs and window function queries

---

## Features

### Data Integrity

| Feature | Implementation |
|---------|---------------|
| Primary Keys | AUTO_INCREMENT on all tables |
| Foreign Keys | ON DELETE/UPDATE rules for referential integrity |
| UNIQUE Constraints | Email addresses, product names |
| CHECK Constraints | Price ≥ 0, quantity > 0, valid order status |
| NOT NULL | All essential fields enforced |
| Timestamps | created_at/updated_at on all tables |

### Enterprise Features

- **Audit Logging**: Automatic tracking of all inventory changes via triggers
- **Transaction Safety**: ACID-compliant stored procedures with rollback
- **Performance Indexes**: 17 indexes for query optimization
- **7 Reporting Views**: Pre-calculated analytics for fast reporting
- **2 Stored Procedures**: Order processing and inventory restock

---

## Database Schema

### Entity-Relationship Diagram

![Database ERD](erd_diagram.jpeg)

### Tables Overview

| Table | Description | Records |
|-------|-------------|---------|
| `Customers` | Customer information with unique email | 20 |
| `Products` | Product catalog with categories | 25 |
| `Inventory` | Stock levels with reorder thresholds | 25 |
| `Orders` | Customer orders with status tracking | 30 |
| `Order_Items` | Bridge table (Orders ↔ Products) | 67 |
| `Inventory_Audit` | Audit log for inventory changes | Dynamic |

### Key Relationships

```
Customers ──(1:N)──> Orders ──(1:N)──> Order_Items <──(N:1)── Products
                                                                  │
                                         Inventory <──(1:1)───────┘
                                             │
                                             v
                                      Inventory_Audit
```

### Foreign Key Cascade Rules

| Relationship | ON DELETE | ON UPDATE |
|--------------|-----------|-----------|
| Orders → Customers | RESTRICT | CASCADE |
| Order_Items → Orders | CASCADE | CASCADE |
| Order_Items → Products | RESTRICT | CASCADE |
| Inventory → Products | CASCADE | CASCADE |
| Inventory_Audit → Products | CASCADE | - |
| Inventory_Audit → Orders | SET NULL | - |

---

## Installation

### Prerequisites

- **MySQL 8.0+** or **MariaDB 10.5+**
- Database client (MySQL Workbench, DBeaver, or CLI)

### Step-by-Step Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Inventory-and-Order-Management-System
   ```

2. **Create the database and schema**
   ```bash
   mysql -u root -p < schema_ddl.sql
   ```

3. **Load sample data**
   ```bash
   mysql -u root -p inventory_management < sample_data.sql
   ```

4. **Create views, triggers, and stored procedures**
   ```bash
   mysql -u root -p inventory_management < queries_dml.sql
   ```

### Verification

Run the following to verify installation:

```sql
USE inventory_management;

-- Check all tables exist
SHOW TABLES;

-- Verify record counts
SELECT 'Customers' AS table_name, COUNT(*) AS records FROM Customers
UNION ALL SELECT 'Products', COUNT(*) FROM Products
UNION ALL SELECT 'Inventory', COUNT(*) FROM Inventory
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Order_Items', COUNT(*) FROM Order_Items
UNION ALL SELECT 'Inventory_Audit', COUNT(*) FROM Inventory_Audit;

-- Check views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Check stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'inventory_management';
```

---

## Usage

### Views

| View | Purpose |
|------|---------|
| `CustomerSalesSummary` | Pre-calculated customer spending metrics |
| `InventoryAuditSummary` | Audit log with product details |
| `ProductInventoryStatus` | Stock levels with status indicators |
| `OrderDetailsSummary` | Complete order information |
| `MonthlySalesReport` | Aggregated monthly metrics |
| `CategoryPerformance` | Sales metrics by category |
| `LowStockAlert` | Products needing reorder |

**Examples:**

```sql
-- View customer analytics
SELECT * FROM CustomerSalesSummary WHERE customer_status = 'VIP';

-- Check low stock products
SELECT * FROM LowStockAlert;

-- Monthly revenue report
SELECT * FROM MonthlySalesReport ORDER BY year DESC, month DESC;
```

### Stored Procedures

#### ProcessNewOrder

Process a new order with automatic inventory management and audit logging.

```sql
CALL ProcessNewOrder(customer_id, product_id, quantity, changed_by);

-- Example: Customer 1 orders 2 units of Product 3
CALL ProcessNewOrder(1, 3, 2, 'SALES_REP');
```

**Features:**
- Transaction-based (ACID compliant)
- Validates customer, product, and stock availability
- Automatically reduces inventory
- Logs change to Inventory_Audit with order reference
- Returns detailed success/error message

#### RestockInventory

Add stock to a product with audit logging.

```sql
CALL RestockInventory(product_id, quantity, changed_by);

-- Example: Add 50 units to Product 5
CALL RestockInventory(5, 50, 'WAREHOUSE_MGR');
```

---

## Audit System

All inventory changes are automatically logged to the `Inventory_Audit` table via database triggers.

### Tracked Actions

| Action Type | Trigger |
|-------------|---------|
| `INSERT` | New inventory record created |
| `UPDATE` | Stock quantity changed |
| `DELETE` | Inventory record deleted |
| `ORDER` | Stock reduced for order fulfillment |
| `RESTOCK` | Stock replenished |

### Audit Log Fields

- `product_id` - Affected product
- `action_type` - Type of change
- `old_quantity` / `new_quantity` - Before/after values
- `quantity_change` - Delta amount
- `change_reason` - Description of why
- `changed_by` - User who made the change
- `changed_at` - Timestamp
- `related_order_id` - Link to order (if applicable)

### Query Audit History

```sql
-- View all inventory changes for a product
SELECT * FROM InventoryAuditSummary 
WHERE product_id = 3 
ORDER BY changed_at DESC;

-- View changes in last 7 days
SELECT * FROM Inventory_Audit 
WHERE changed_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY changed_at DESC;
```

---

## Sample Queries

### Business KPIs

```sql
-- Total Revenue (completed orders only)
SELECT SUM(total_amount) AS total_revenue
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered');

-- Top 10 Customers by spending
SELECT c.full_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Best-selling products
SELECT p.product_name, SUM(oi.quantity) AS units_sold
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY units_sold DESC
LIMIT 5;
```

### Window Functions

```sql
-- Rank products by revenue within category
SELECT category, product_name,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
FROM (
    SELECT p.category, p.product_name, 
           SUM(oi.quantity * oi.price_at_purchase) AS revenue
    FROM Products p
    JOIN Order_Items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
) ranked;

-- Customer order frequency with previous order date
SELECT customer_id, order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order
FROM Orders;
```

---

## Project Structure

```
Inventory-and-Order-Management-System/
├── README.md              # This documentation
├── erd_diagram.jpeg       # Entity-Relationship Diagram
├── schema_ddl.sql         # Database creation (DDL)
├── sample_data.sql        # Test data
└── queries_dml.sql        # Queries, views, triggers, procedures (DML)
```

---

## Technical Specifications

| Specification | Details |
|--------------|---------|
| Database | MySQL 8.0+ / MariaDB 10.5+ |
| Normalization | Third Normal Form (3NF) |
| Tables | 6 |
| Views | 7 |
| Stored Procedures | 2 |
| Triggers | 3 |
| Indexes | 17 |

---

## License

This project was created as a capstone for SQL database design and implementation.
