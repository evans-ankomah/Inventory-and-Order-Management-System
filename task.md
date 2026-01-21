Lab: Inventory and Order Management System
Project Overview
This project is your capstone for the SQL module. You will design, build, and query a database for an e-commerce company's inventory and order management system. This will require you to apply your knowledge of data modeling, schema implementation (DDL), and advanced SQL querying (DML) to solve realistic business problems.

This is an independent project. You will be responsible for the complete database lifecycle, from design to analysis.

Project Objectives
Database Design: Design a normalized, relational database schema (3NF) based on a set of business requirements.

Schema Implementation: Write and execute SQL Data Definition Language (DDL) scripts to create the database tables, relationships, and constraints.

Advanced Querying: Implement complex SQL queries, including joins, aggregations, window functions, and stored procedures to answer key business questions.

Performance Optimization: Use views and stored procedures to create reusable, performant query logic.

Project Steps
Step 1: Database Design (ERD & Schema)
Your first task is to design the database. Before writing any SQL, create an Entity-Relationship Diagram (ERD) that maps out the tables, their columns, and their relationships.

Business Requirements:

The system must be able to track the following:

Customers:

Customer ID

Full Name

Email

Phone

Shipping Address

Products:

Product ID

Product Name

Category (e.g., Electronics, Apparel, Books)

Price

Inventory:

A way to track the current stock level (quantity on hand) for each product.

Orders:

Order ID

The Customer ID who placed the order.

Order Date

Total Order Amount

Order Status (e.g., 'Pending', 'Shipped', 'Delivered')

Order Items:

A single order can contain multiple products.

You must have a table that links products to orders.

This table must store the Order ID, Product ID, Quantity of the product ordered, and the Price at the time of purchase.

Step 2: Schema Implementation (DDL)
Translate your ERD into a functional database.

Write CREATE TABLE Scripts: Write the SQL DDL statements to create all the tables you designed in Step 1.

Enforce Data Integrity: Use the correct data types for each column (e.g., VARCHAR, INT, DECIMAL, DATE).

Define Keys & Constraints:

Implement PRIMARY KEY constraints for all ID fields.

Implement FOREIGN KEY constraints to link your tables (e.g., link Order Items to Orders and Products).

Add NOT NULL constraints to essential fields (like Customer Name, Product Name, Order Date).

Add a CHECK constraint to ensure Product Price and Inventory Quantity are always non-negative.

Note: Pay close attention to the relationships. A Customer can have many Orders, and an Order can have many Products (a many-to-many relationship that requires a "bridge" table, which is your Order Items table).

Step 3: KPI & Advanced SQL Querying (DML)
Your database is built. Now, populate it with some sample data and write queries to answer the following business questions.

Business KPIs (Write as standard SELECT queries):

Total Revenue: Calculate the total revenue from all 'Shipped' or 'Delivered' orders.

Top 10 Customers: Find the top 10 customers by their total spending. Show Customer Name and Total Amount Spent.

Best-Selling Products: List the top 5 best-selling products by quantity sold.

Monthly Sales Trend: Show the total sales revenue for each month.

Analytical Queries (Use Window Functions):

Sales Rank by Category: For each product category, rank the products by their total sales revenue. The #1 product in 'Electronics', the #1 in 'Apparel', etc.

Customer Order Frequency: Show a list of customers and the date of their previous order alongside the date of their current order. This helps analyze how frequently customers return.

Performance Optimization (Create Views & Stored Procedures):

Create a CustomerSalesSummary View: Build a view that pre-calculates the total amount spent by each customer. This view will make it easier to query for customer analytics.

Create a ProcessNewOrder Stored Procedure:

This procedure should accept Customer ID, Product ID, and Quantity as inputs.

It must perform the following actions within a transaction:

Check if there is enough stock in the Inventory.

If stock is sufficient, reduce the Inventory quantity.

Create a new record in the Orders table.

Create a new record in the Order Items table.

If stock is insufficient, it should roll back the transaction and return an error message.

Project Deliverables
You must submit the following:

ERD Diagram: A clear diagram (e.g., a PNG or PDF) of your database schema.

SQL DDL Script: A single .sql file containing all your CREATE TABLE statements.

SQL DML Script: A single .sql file containing all your queries, views, and stored procedures from Step 3, with clear comments labeling each question.

Last modified: Monday, 10 November 2025, 7:46 PM