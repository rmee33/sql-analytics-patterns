/*
Purpose:
Identify and remove duplicate records using window functions.
*/

-- Identify duplicate orders (same customer, same date, same amount)
SELECT
    customer_id,
    order_date,
    order_amount,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY customer_id, order_date, order_amount
HAVING COUNT(*) > 1;


-- Flag duplicates using ROW_NUMBER
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, order_date, order_amount
            ORDER BY order_id
        ) AS rn
    FROM orders
) sub
WHERE rn > 1;


-- Delete duplicates (example pattern)
-- DELETE FROM orders
-- WHERE order_id IN (
--     SELECT order_id
--     FROM (
--         SELECT
--             order_id,
--             ROW_NUMBER() OVER (
--                 PARTITION BY customer_id, order_date, order_amount
--                 ORDER BY order_id
--             ) AS rn
--         FROM orders
--     ) t
--     WHERE rn > 1
-- );
