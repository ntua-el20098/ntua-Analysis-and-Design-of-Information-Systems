-- without join 

-- Define constants
WITH params AS (
    SELECT CAST(FLOOR(1176 + RAND() * (1224 - 1176 + 1)) AS INTEGER) AS dms
),
aggregated_data AS (
    -- Average revenue per store
    SELECT 
        ss_store_sk,
        AVG(revenue) AS ave
    FROM (
        SELECT  
            ss_store_sk,
            ss_item_sk,
            SUM(ss_sales_price) AS revenue
        FROM 
            store_sales, 
            date_dim, 
            params
        WHERE 
            ss_sold_date_sk = d_date_sk 
            AND d_month_seq BETWEEN params.dms AND params.dms + 11
        GROUP BY 
            ss_store_sk, 
            ss_item_sk
    ) sa
    GROUP BY 
        ss_store_sk
),
revenue_data AS (
    -- Revenue per store and item
    SELECT  
        ss_store_sk,
        ss_item_sk,
        SUM(ss_sales_price) AS revenue
    FROM 
        store_sales, 
        date_dim, 
        params
    WHERE 
        ss_sold_date_sk = d_date_sk 
        AND d_month_seq BETWEEN params.dms AND params.dms + 11
    GROUP BY 
        ss_store_sk, 
        ss_item_sk
)
-- Final query
SELECT 
    s_store_name,
    i_item_desc,
    sc.revenue,
    i_current_price,
    i_wholesale_cost,
    i_brand
FROM 
    store, 
    item, 
    aggregated_data sb, 
    revenue_data sc
WHERE 
    sb.ss_store_sk = sc.ss_store_sk 
    AND sc.revenue <= 0.1 * sb.ave 
    AND s_store_sk = sc.ss_store_sk 
    AND i_item_sk = sc.ss_item_sk
ORDER BY 
    s_store_name, 
    i_item_desc
LIMIT 100;



-- with join

-- Define constants
WITH params AS (
    SELECT CAST(FLOOR(1176 + RAND() * (1224 - 1176 + 1)) AS INTEGER) AS dms
),
aggregated_data AS (
    -- Average revenue per store
    SELECT 
        ss_store_sk,
        AVG(revenue) AS ave
    FROM (
        SELECT  
            ss_store_sk,
            ss_item_sk,
            SUM(ss_sales_price) AS revenue
        FROM 
            store_sales
        JOIN date_dim 
            ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
        CROSS JOIN params
        WHERE 
            date_dim.d_month_seq BETWEEN params.dms AND params.dms + 11
        GROUP BY 
            ss_store_sk, 
            ss_item_sk
    ) sa
    GROUP BY 
        ss_store_sk
),
revenue_data AS (
    -- Revenue per store and item
    SELECT  
        ss_store_sk,
        ss_item_sk,
        SUM(ss_sales_price) AS revenue
    FROM 
        store_sales
    JOIN date_dim 
        ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
    CROSS JOIN params
    WHERE 
        date_dim.d_month_seq BETWEEN params.dms AND params.dms + 11
    GROUP BY 
        ss_store_sk, 
        ss_item_sk
)
-- Final query
SELECT 
    s_store_name,
    i_item_desc,
    sc.revenue,
    i_current_price,
    i_wholesale_cost,
    i_brand
FROM 
    revenue_data sc
JOIN aggregated_data sb 
    ON sc.ss_store_sk = sb.ss_store_sk 
    AND sc.revenue <= 0.1 * sb.ave
JOIN store 
    ON sc.ss_store_sk = store.s_store_sk
JOIN item 
    ON sc.ss_item_sk = item.i_item_sk
ORDER BY 
    s_store_name, 
    i_item_desc
LIMIT 100;
