-- postgresql,cassandra ok

WITH params AS (
    -- Define the DMS value directly (example: 1176)
    SELECT 1176 AS dms, -- You can change this to any value you need
           100 AS limit_count -- Static limit value
),
web_v1 AS (
    SELECT ws_item_sk AS item_sk,
           d_date,
           SUM(SUM(ws_sales_price)) 
               OVER (PARTITION BY ws_item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cume_sales
    FROM web_sales,
         date_dim,
         params p
    WHERE ws_sold_date_sk = d_date_sk
      AND d_month_seq BETWEEN p.dms AND p.dms + 11 -- Use the DMS value from the params
      AND ws_item_sk IS NOT NULL
    GROUP BY ws_item_sk, d_date
),
store_v1 AS (
    SELECT ss_item_sk AS item_sk,
           d_date,
           SUM(SUM(ss_sales_price)) 
               OVER (PARTITION BY ss_item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cume_sales
    FROM store_sales,
         date_dim,
         params p
    WHERE ss_sold_date_sk = d_date_sk
      AND d_month_seq BETWEEN p.dms AND p.dms + 11 -- Use the DMS value from the params
      AND ss_item_sk IS NOT NULL
    GROUP BY ss_item_sk, d_date
)
SELECT *
FROM (
    SELECT item_sk,
           d_date,
           web_sales,
           store_sales,
           MAX(web_sales) OVER (PARTITION BY item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS web_cumulative,
           MAX(store_sales) OVER (PARTITION BY item_sk ORDER BY d_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS store_cumulative
    FROM (
        SELECT CASE 
                   WHEN web.item_sk IS NOT NULL THEN web.item_sk 
                   ELSE store.item_sk 
               END AS item_sk,
               CASE 
                   WHEN web.d_date IS NOT NULL THEN web.d_date 
                   ELSE store.d_date 
               END AS d_date,
               web.cume_sales AS web_sales,
               store.cume_sales AS store_sales
        FROM web_v1 web
        FULL OUTER JOIN store_v1 store 
            ON web.item_sk = store.item_sk
            AND web.d_date = store.d_date
    ) x
) y
WHERE web_cumulative > store_cumulative
ORDER BY item_sk, d_date
LIMIT 100