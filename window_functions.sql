/*
Purpose:
Demonstrate window functions for analytics without collapsing rows.
*/

-- Rank orders by amount within each customer
SELECT
    customer_id,
    order_id,
    order_amount,
    RANK() OVER (
        PARTITION BY customer_id
        ORDER BY order_amount DESC
    ) AS order_rank
FROM orders;


-- Running total of spend per customer
SELECT
    customer_id,
    order_date,
    order_amount,
    SUM(order_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders;


-- Identify the most recent order per customer
SELECT *
FROM (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn
    FROM orders
) sub
WHERE rn = 1;
