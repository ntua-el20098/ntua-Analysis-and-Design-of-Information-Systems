WITH 
cross_items AS (
    SELECT i_item_sk AS ss_item_sk
    FROM item
    WHERE EXISTS (
        SELECT 1
        FROM store_sales
        JOIN item iss ON ss_item_sk = iss.i_item_sk
        JOIN date_dim d1 ON ss_sold_date_sk = d1.d_date_sk
        WHERE d1.d_year BETWEEN [YEAR] AND [YEAR] + 2
        INTERSECT 
        SELECT 1
        FROM catalog_sales
        JOIN item ics ON cs_item_sk = ics.i_item_sk
        JOIN date_dim d2 ON cs_sold_date_sk = d2.d_date_sk
        WHERE d2.d_year BETWEEN [YEAR] AND [YEAR] + 2
        INTERSECT
        SELECT 1
        FROM web_sales
        JOIN item iws ON ws_item_sk = iws.i_item_sk
        JOIN date_dim d3 ON ws_sold_date_sk = d3.d_date_sk
        WHERE d3.d_year BETWEEN [YEAR] AND [YEAR] + 2
    )
),
avg_sales AS (
    SELECT AVG(quantity * list_price) AS average_sales
    FROM (
        SELECT ss_quantity AS quantity, ss_list_price AS list_price
        FROM store_sales
        JOIN date_dim ON ss_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2
        UNION ALL 
        SELECT cs_quantity AS quantity, cs_list_price AS list_price
        FROM catalog_sales
        JOIN date_dim ON cs_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2 
        UNION ALL
        SELECT ws_quantity AS quantity, ws_list_price AS list_price
        FROM web_sales
        JOIN date_dim ON ws_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2
    ) AS x
)
SELECT 
    [LIMITB] channel, i_brand_id, i_class_id, i_category_id, 
    SUM(sales) AS total_sales, SUM(number_sales) AS total_number_sales
FROM (
    SELECT 'store' AS channel, i_brand_id, i_class_id, i_category_id,
           SUM(ss_quantity * ss_list_price) AS sales,
           COUNT(*) AS number_sales
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE ss_item_sk IN (SELECT ss_item_sk FROM cross_items)
      AND d_year = [YEAR] + 2
      AND d_moy = 11
    GROUP BY i_brand_id, i_class_id, i_category_id
    HAVING SUM(ss_quantity * ss_list_price) > (SELECT average_sales FROM avg_sales)
    
    UNION ALL
    
    SELECT 'catalog' AS channel, i_brand_id, i_class_id, i_category_id,
           SUM(cs_quantity * cs_list_price) AS sales, COUNT(*) AS number_sales
    FROM catalog_sales
    JOIN item ON cs_item_sk = i_item_sk
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE cs_item_sk IN (SELECT ss_item_sk FROM cross_items)
      AND d_year = [YEAR] + 2
      AND d_moy = 11
    GROUP BY i_brand_id, i_class_id, i_category_id
    HAVING SUM(cs_quantity * cs_list_price) > (SELECT average_sales FROM avg_sales)
    
    UNION ALL
    
    SELECT 'web' AS channel, i_brand_id, i_class_id, i_category_id,
           SUM(ws_quantity * ws_list_price) AS sales, COUNT(*) AS number_sales
    FROM web_sales
    JOIN item ON ws_item_sk = i_item_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE ws_item_sk IN (SELECT ss_item_sk FROM cross_items)
      AND d_year = [YEAR] + 2
      AND d_moy = 11
    GROUP BY i_brand_id, i_class_id, i_category_id
    HAVING SUM(ws_quantity * ws_list_price) > (SELECT average_sales FROM avg_sales)
) AS sales_data
GROUP BY ROLLUP(channel, i_brand_id, i_class_id, i_category_id)
ORDER BY channel, i_brand_id, i_class_id, i_category_id
LIMIT 100

-- Second query section

WITH 
cross_items AS (
    SELECT i_item_sk AS ss_item_sk
    FROM item
    WHERE EXISTS (
        SELECT 1
        FROM store_sales
        JOIN item iss ON ss_item_sk = iss.i_item_sk
        JOIN date_dim d1 ON ss_sold_date_sk = d1.d_date_sk
        WHERE d1.d_year BETWEEN [YEAR] AND [YEAR] + 2
        INTERSECT 
        SELECT 1
        FROM catalog_sales
        JOIN item ics ON cs_item_sk = ics.i_item_sk
        JOIN date_dim d2 ON cs_sold_date_sk = d2.d_date_sk
        WHERE d2.d_year BETWEEN [YEAR] AND [YEAR] + 2
        INTERSECT
        SELECT 1
        FROM web_sales
        JOIN item iws ON ws_item_sk = iws.i_item_sk
        JOIN date_dim d3 ON ws_sold_date_sk = d3.d_date_sk
        WHERE d3.d_year BETWEEN [YEAR] AND [YEAR] + 2
    )
),
avg_sales AS (
    SELECT AVG(quantity * list_price) AS average_sales
    FROM (
        SELECT ss_quantity AS quantity, ss_list_price AS list_price
        FROM store_sales
        JOIN date_dim ON ss_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2
        UNION ALL 
        SELECT cs_quantity AS quantity, cs_list_price AS list_price
        FROM catalog_sales
        JOIN date_dim ON cs_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2
        UNION ALL
        SELECT ws_quantity AS quantity, ws_list_price AS list_price
        FROM web_sales
        JOIN date_dim ON ws_sold_date_sk = d_date_sk
        WHERE d_year BETWEEN [YEAR] AND [YEAR] + 2
    ) AS x
)
SELECT 
    [LIMITB] this_year.channel AS ty_channel,
    this_year.i_brand_id AS ty_brand,
    this_year.i_class_id AS ty_class,
    this_year.i_category_id AS ty_category,
    this_year.sales AS ty_sales,
    this_year.number_sales AS ty_number_sales,
    last_year.channel AS ly_channel,
    last_year.i_brand_id AS ly_brand,
    last_year.i_class_id AS ly_class,
    last_year.i_category_id AS ly_category,
    last_year.sales AS ly_sales,
    last_year.number_sales AS ly_number_sales
FROM (
    SELECT 'store' AS channel, i_brand_id, i_class_id, i_category_id,
           SUM(ss_quantity * ss_list_price) AS sales,
           COUNT(*) AS number_sales
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE ss_item_sk IN (SELECT ss_item_sk FROM cross_items)
      AND d_week_seq = (SELECT d_week_seq
                        FROM date_dim
                        WHERE d_year = [YEAR] + 1
                          AND d_moy = 12
                          AND d_dom = [DAY])
    GROUP BY i_brand_id, i_class_id, i_category_id
    HAVING SUM(ss_quantity * ss_list_price) > (SELECT average_sales FROM avg_sales)
) AS this_year
JOIN (
    SELECT 'store' AS channel, i_brand_id, i_class_id, i_category_id,
           SUM(ss_quantity * ss_list_price) AS sales,
           COUNT(*) AS number_sales
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE ss_item_sk IN (SELECT ss_item_sk FROM cross_items)
      AND d_week_seq = (SELECT d_week_seq
                        FROM date_dim
                        WHERE d_year = [YEAR]
                          AND d_moy = 12
                          AND d_dom = [DAY])
    GROUP BY i_brand_id, i_class_id, i_category_id
    HAVING SUM(ss_quantity * ss_list_price) > (SELECT average_sales FROM avg_sales)
) AS last_year
ON this_year.i_brand_id = last_year.i_brand_id
   AND this_year.i_class_id = last_year.i_class_id
   AND this_year.i_category_id = last_year.i_category_id
ORDER BY this_year.channel, this_year.i_brand_id, this_year.i_class_id, this_year.i_category_id
LIMIT 100
