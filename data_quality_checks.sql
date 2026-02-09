/*
Purpose:
Basic data quality and validation checks for analytics datasets.
*/

-- Check for nulls in key fields
SELECT *
FROM orders
WHERE customer_id IS NULL
   OR order_date IS NULL
   OR order_amount IS NULL;


-- Check for negative or zero order amounts
SELECT *
FROM orders
WHERE order_amount <= 0;


-- Check for orphaned records (orders without customers)
SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Check date ranges (future dates)
SELECT *
FROM orders
WHERE order_date > CURRENT_DATE;


-- Record counts for monitoring
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;
