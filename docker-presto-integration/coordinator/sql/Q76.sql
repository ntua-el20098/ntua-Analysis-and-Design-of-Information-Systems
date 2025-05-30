-- without join

WITH sales_data AS (
    -- Store Sales
    SELECT 
        'store' AS channel, 
        'ss_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        ss_ext_sales_price AS ext_sales_price
    FROM store_sales, item, date_dim
    WHERE ss_customer_sk IS NULL
      AND ss_cdemo_sk IS NULL
      AND ss_hdemo_sk IS NULL
      AND ss_addr_sk IS NULL
      AND ss_store_sk IS NULL
      AND ss_promo_sk IS NULL
      AND ss_sold_date_sk = d_date_sk
      AND ss_item_sk = i_item_sk

    UNION ALL

    -- Web Sales
    SELECT 
        'web' AS channel, 
        'ws_bill_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        ws_ext_sales_price AS ext_sales_price
    FROM web_sales, item, date_dim
    WHERE ws_bill_customer_sk IS NULL
      AND ws_bill_hdemo_sk IS NULL
      AND ws_bill_addr_sk IS NULL
      AND ws_ship_customer_sk IS NULL
      AND ws_ship_cdemo_sk IS NULL
      AND ws_ship_hdemo_sk IS NULL
      AND ws_ship_addr_sk IS NULL
      AND ws_web_page_sk IS NULL
      AND ws_web_site_sk IS NULL
      AND ws_ship_mode_sk IS NULL
      AND ws_warehouse_sk IS NULL
      AND ws_promo_sk IS NULL
      AND ws_sold_date_sk = d_date_sk
      AND ws_item_sk = i_item_sk

    UNION ALL

    -- Catalog Sales
    SELECT 
        'catalog' AS channel, 
        'cs_bill_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        cs_ext_sales_price AS ext_sales_price
    FROM catalog_sales, item, date_dim
    WHERE cs_bill_customer_sk IS NULL
      AND cs_bill_hdemo_sk IS NULL
      AND cs_bill_addr_sk IS NULL
      AND cs_ship_customer_sk IS NULL
      AND cs_ship_cdemo_sk IS NULL
      AND cs_ship_hdemo_sk IS NULL
      AND cs_ship_addr_sk IS NULL
      AND cs_ship_mode_sk IS NULL
      AND cs_warehouse_sk IS NULL
      AND cs_promo_sk IS NULL
      AND cs_sold_date_sk = d_date_sk
      AND cs_item_sk = i_item_sk
)
-- Final Aggregation
SELECT 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category, 
    COUNT(*) AS sales_cnt, 
    SUM(ext_sales_price) AS sales_amt
FROM sales_data
GROUP BY 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category
ORDER BY 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category
LIMIT 100;

-- with join 
WITH sales_data AS (
    -- Store Sales
    SELECT 
        'store' AS channel, 
        'ss_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        ss_ext_sales_price AS ext_sales_price
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE ss_customer_sk IS NULL
      AND ss_cdemo_sk IS NULL
      AND ss_hdemo_sk IS NULL
      AND ss_addr_sk IS NULL
      AND ss_store_sk IS NULL
      AND ss_promo_sk IS NULL

    UNION ALL

    -- Web Sales
    SELECT 
        'web' AS channel, 
        'ws_bill_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        ws_ext_sales_price AS ext_sales_price
    FROM web_sales
    JOIN item ON ws_item_sk = i_item_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE ws_bill_customer_sk IS NULL
      AND ws_bill_hdemo_sk IS NULL
      AND ws_bill_addr_sk IS NULL
      AND ws_ship_customer_sk IS NULL
      AND ws_ship_cdemo_sk IS NULL
      AND ws_ship_hdemo_sk IS NULL
      AND ws_ship_addr_sk IS NULL
      AND ws_web_page_sk IS NULL
      AND ws_web_site_sk IS NULL
      AND ws_ship_mode_sk IS NULL
      AND ws_warehouse_sk IS NULL
      AND ws_promo_sk IS NULL

    UNION ALL

    -- Catalog Sales
    SELECT 
        'catalog' AS channel, 
        'cs_bill_customer_sk' AS col_name, 
        d_year, 
        d_qoy, 
        i_category, 
        cs_ext_sales_price AS ext_sales_price
    FROM catalog_sales
    JOIN item ON cs_item_sk = i_item_sk
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE cs_bill_customer_sk IS NULL
      AND cs_bill_hdemo_sk IS NULL
      AND cs_bill_addr_sk IS NULL
      AND cs_ship_customer_sk IS NULL
      AND cs_ship_cdemo_sk IS NULL
      AND cs_ship_hdemo_sk IS NULL
      AND cs_ship_addr_sk IS NULL
      AND cs_ship_mode_sk IS NULL
      AND cs_warehouse_sk IS NULL
      AND cs_promo_sk IS NULL
)
-- Final Aggregation
SELECT 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category, 
    COUNT(*) AS sales_cnt, 
    SUM(ext_sales_price) AS sales_amt
FROM sales_data
GROUP BY 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category
ORDER BY 
    channel, 
    col_name, 
    d_year, 
    d_qoy, 
    i_category
LIMIT 100;
