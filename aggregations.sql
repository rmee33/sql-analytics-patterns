/*
Purpose:
Show how to summarize data using GROUP BY and aggregate functions.
*/

-- Total spend per customer
SELECT
    customer_id,
    SUM(order_amount) AS total_spend
FROM orders
GROUP BY customer_id;


-- Average order value by month
SELECT
    DATE_TRUNC('month', order_date) AS order_month,
    AVG(order_amount) AS avg_order_value
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;


-- Count of orders by customer, filtering to active customers
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 5;
