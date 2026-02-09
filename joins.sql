/*
Purpose:
Demonstrate common SQL join patterns used in analytics.

Tables:
customers(customer_id, customer_name)
orders(order_id, customer_id, order_date, order_amount)
*/

-- INNER JOIN: only customers with orders
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_amount
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;


-- LEFT JOIN: keep all customers, even those without orders
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- Identify customers with NO orders
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
