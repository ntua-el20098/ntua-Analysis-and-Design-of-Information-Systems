-- postgresql, cassandra ok

WITH params AS (
    SELECT CAST('1998-01-31' AS DATE) AS sales_date, -- Replace with random logic if needed
           100 AS limit_count
)
SELECT *
FROM (
    SELECT w.w_warehouse_name,
           i.i_item_id,
           SUM(CASE WHEN DATE_TRUNC('day', CAST(d.d_date AS DATE)) < p.sales_date THEN inv.inv_quantity_on_hand ELSE 0 END) AS inv_before,
           SUM(CASE WHEN DATE_TRUNC('day', CAST(d.d_date AS DATE)) >= p.sales_date THEN inv.inv_quantity_on_hand ELSE 0 END) AS inv_after
    FROM postgresql.public.inventory inv
    JOIN mongodb.sf1.warehouse w ON inv.inv_warehouse_sk = w.w_warehouse_sk
    JOIN mongodb.sf1.item i ON inv.inv_item_sk = i.i_item_sk
    JOIN postgresql.public.date_dim d ON inv.inv_date_sk = d.d_date_sk
    CROSS JOIN params p
    WHERE i.i_current_price BETWEEN 0.99 AND 1.49
      AND DATE_TRUNC('day', CAST(d.d_date AS DATE)) BETWEEN (p.sales_date - INTERVAL '30' DAY) AND (p.sales_date + INTERVAL '30' DAY)
    GROUP BY w.w_warehouse_name, i.i_item_id
) x
WHERE (CASE WHEN inv_before > 0 THEN inv_after / inv_before ELSE NULL END) BETWEEN 2.0/3.0 AND 3.0/2.0
ORDER BY w_warehouse_name, i_item_id
LIMIT 100
