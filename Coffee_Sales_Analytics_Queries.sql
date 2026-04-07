/*
===============================================================================
  COFFEE SHOP SALES ANALYTICS - SQL QUERIES
  Database: Coffee_Sales_DB
  Author: Parth Mistry
  Purpose: Business Intelligence & Sales Analytics
  Tools: SQL Server Management Studio (SSMS) / MySQL
===============================================================================
*/

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================

USE Coffee_Sales_DB;
GO

-- ============================================================================
-- BUSINESS QUESTION 1: What are the total sales and transaction counts?
-- Purpose: Get overall business performance metrics
-- ============================================================================

SELECT 
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales,
    ROUND(AVG(transaction_qty * unit_price), 2) AS average_transaction_value
FROM coffee_shop_sales;

-- ============================================================================
-- BUSINESS QUESTION 2: What are the monthly sales trends?
-- Purpose: Identify sales patterns and seasonality
-- ============================================================================

SELECT 
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    DATENAME(MONTH, transaction_date) AS month_name,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM coffee_shop_sales
GROUP BY YEAR(transaction_date), MONTH(transaction_date), DATENAME(MONTH, transaction_date)
ORDER BY year, month;

-- ============================================================================
-- BUSINESS QUESTION 3: What are the sales by day of week?
-- Purpose: Optimize staffing and inventory based on daily patterns
-- ============================================================================

SELECT 
    DATENAME(WEEKDAY, transaction_date) AS day_of_week,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_transaction_value
FROM coffee_shop_sales
GROUP BY DATENAME(WEEKDAY, transaction_date), DATEPART(WEEKDAY, transaction_date)
ORDER BY DATEPART(WEEKDAY, transaction_date);

-- ============================================================================
-- BUSINESS QUESTION 4: What are the hourly sales patterns?
-- Purpose: Identify peak hours for staffing optimization
-- ============================================================================

SELECT 
    DATEPART(HOUR, transaction_time) AS hour_of_day,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM coffee_shop_sales
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY hour_of_day;

-- ============================================================================
-- BUSINESS QUESTION 5: Which products are top sellers?
-- Purpose: Product portfolio optimization and inventory management
-- ============================================================================

SELECT TOP 10
    product_category,
    product_type,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_order_value
FROM coffee_shop_sales
GROUP BY product_category, product_type
ORDER BY total_revenue DESC;

-- ============================================================================
-- BUSINESS QUESTION 6: What is the sales performance by store location?
-- Purpose: Identify high and low performing stores
-- ============================================================================

SELECT 
    store_location,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_transaction_value,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_shop_sales
GROUP BY store_location
ORDER BY total_sales DESC;

-- ============================================================================
-- BUSINESS QUESTION 7: What is the product category performance?
-- Purpose: Category-level revenue analysis
-- ============================================================================

SELECT 
    product_category,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS category_revenue,
    ROUND(SUM(transaction_qty * unit_price) * 100.0 / 
        (SELECT SUM(transaction_qty * unit_price) FROM coffee_shop_sales), 2) AS revenue_percentage,
    SUM(transaction_qty) AS total_quantity
FROM coffee_shop_sales
GROUP BY product_category
ORDER BY category_revenue DESC;

-- ============================================================================
-- BUSINESS QUESTION 8: What are the sales by product size?
-- Purpose: Understand customer preferences for upselling
-- ============================================================================

SELECT 
    product_detail AS product_size,
    COUNT(transaction_id) AS total_orders,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue,
    ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM coffee_shop_sales
WHERE product_detail IS NOT NULL
GROUP BY product_detail
ORDER BY total_revenue DESC;

-- ============================================================================
-- BUSINESS QUESTION 9: What is the month-over-month growth rate?
-- Purpose: Track business growth trends
-- ============================================================================

WITH monthly_sales AS (
    SELECT 
        YEAR(transaction_date) AS year,
        MONTH(transaction_date) AS month,
        ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_revenue
    FROM coffee_shop_sales
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
SELECT 
    year,
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
    ROUND(((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month)) 
        / LAG(monthly_revenue) OVER (ORDER BY year, month)) * 100, 2) AS growth_percentage
FROM monthly_sales
ORDER BY year, month;

-- ============================================================================
-- BUSINESS QUESTION 10: What are the peak sales days in each month?
-- Purpose: Identify promotional opportunities
-- ============================================================================

SELECT TOP 20
    CONVERT(DATE, transaction_date) AS sales_date,
    DATENAME(WEEKDAY, transaction_date) AS day_name,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS daily_revenue
FROM coffee_shop_sales
GROUP BY CONVERT(DATE, transaction_date), DATENAME(WEEKDAY, transaction_date)
ORDER BY daily_revenue DESC;

-- ============================================================================
-- BUSINESS QUESTION 11: What is the customer basket analysis?
-- Purpose: Cross-selling and bundling opportunities
-- ============================================================================

SELECT 
    transaction_id,
    COUNT(DISTINCT product_category) AS categories_per_transaction,
    SUM(transaction_qty) AS items_per_transaction,
    ROUND(SUM(transaction_qty * unit_price), 2) AS transaction_value
FROM coffee_shop_sales
GROUP BY transaction_id
HAVING COUNT(DISTINCT product_category) > 1
ORDER BY transaction_value DESC;

-- ============================================================================
-- BUSINESS QUESTION 12: What are the sales by time periods (Morning/Afternoon/Evening)?
-- Purpose: Time-based marketing and operations planning
-- ============================================================================

SELECT 
    CASE 
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 6 AND 11 THEN 'Morning (6 AM - 11 AM)'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 12 AND 17 THEN 'Afternoon (12 PM - 5 PM)'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 18 AND 23 THEN 'Evening (6 PM - 11 PM)'
        ELSE 'Night (12 AM - 5 AM)'
    END AS time_period,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_transaction_value
FROM coffee_shop_sales
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 6 AND 11 THEN 'Morning (6 AM - 11 AM)'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 12 AND 17 THEN 'Afternoon (12 PM - 5 PM)'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 18 AND 23 THEN 'Evening (6 PM - 11 PM)'
        ELSE 'Night (12 AM - 5 AM)'
    END
ORDER BY total_sales DESC;

-- ============================================================================
-- BUSINESS QUESTION 13: What is the average transaction value by store and product category?
-- Purpose: Store-level product performance analysis
-- ============================================================================

SELECT 
    store_location,
    product_category,
    COUNT(transaction_id) AS transactions,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_transaction_value,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM coffee_shop_sales
GROUP BY store_location, product_category
ORDER BY store_location, total_revenue DESC;

-- ============================================================================
-- BUSINESS QUESTION 14: Which products have the highest profit margins?
-- Purpose: Identify most profitable items (assuming cost data available)
-- Note: This query assumes a 'unit_cost' column exists
-- ============================================================================

-- SELECT 
--     product_category,
--     product_type,
--     ROUND(AVG(unit_price), 2) AS avg_selling_price,
--     ROUND(AVG(unit_cost), 2) AS avg_cost,
--     ROUND(AVG(unit_price - unit_cost), 2) AS avg_profit_per_unit,
--     ROUND(((AVG(unit_price) - AVG(unit_cost)) / AVG(unit_price)) * 100, 2) AS profit_margin_percentage
-- FROM coffee_shop_sales
-- GROUP BY product_category, product_type
-- ORDER BY profit_margin_percentage DESC;

-- ============================================================================
-- BUSINESS QUESTION 15: What is the sales forecast based on historical trends?
-- Purpose: Predictive analytics for inventory and staffing
-- ============================================================================

WITH daily_sales AS (
    SELECT 
        CONVERT(DATE, transaction_date) AS sales_date,
        ROUND(SUM(transaction_qty * unit_price), 2) AS daily_revenue
    FROM coffee_shop_sales
    GROUP BY CONVERT(DATE, transaction_date)
)
SELECT 
    sales_date,
    daily_revenue,
    ROUND(AVG(daily_revenue) OVER (ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS seven_day_moving_avg
FROM daily_sales
ORDER BY sales_date DESC;

-- ============================================================================
-- PERFORMANCE METRICS SUMMARY
-- Purpose: Executive dashboard KPIs
-- ============================================================================

SELECT 
    'Total Revenue' AS metric,
    CONCAT('$', FORMAT(SUM(transaction_qty * unit_price), 'N2')) AS value
FROM coffee_shop_sales
UNION ALL
SELECT 
    'Total Transactions',
    FORMAT(COUNT(transaction_id), 'N0')
FROM coffee_shop_sales
UNION ALL
SELECT 
    'Average Transaction Value',
    CONCAT('$', FORMAT(AVG(transaction_qty * unit_price), 'N2'))
FROM coffee_shop_sales
UNION ALL
SELECT 
    'Total Items Sold',
    FORMAT(SUM(transaction_qty), 'N0')
FROM coffee_shop_sales
UNION ALL
SELECT 
    'Unique Products',
    FORMAT(COUNT(DISTINCT product_type), 'N0')
FROM coffee_shop_sales;

-- ============================================================================
-- END OF QUERIES
-- ============================================================================

/*
NOTES:
1. Adjust database name (Coffee_Sales_DB) based on your setup
2. For MySQL, replace DATENAME with DATE_FORMAT
3. For MySQL, replace TOP with LIMIT
4. Date functions may vary between SQL Server and MySQL
5. Add appropriate indexes on date and category columns for performance

SCHEMA ASSUMPTIONS:
- transaction_id: Unique identifier
- transaction_date: DATE type
- transaction_time: TIME type
- transaction_qty: INT
- unit_price: DECIMAL(10,2)
- product_category: VARCHAR
- product_type: VARCHAR
- product_detail: VARCHAR
- store_location: VARCHAR
*/
