-- postgresql ok, cassandra problematic

WITH 
    -- Defining the YEAR, MONTH, and STATE variables
    year AS (SELECT 1999 AS year),
    month AS (SELECT 5 AS month),
    state AS (SELECT 'TX' AS state),  -- Static value for STATE (e.g., 'TX' for Texas)

  sales_data AS (
    SELECT 
        COUNT(DISTINCT ws1.ws_order_number) AS "order count",
        SUM(ws1.ws_ext_ship_cost) AS "total shipping cost",
        SUM(ws1.ws_net_profit) AS "total net profit"
    FROM 
        postgresql.public.web_sales ws1,
        postgresql.public.date_dim,
        cassandra.keyspace_sf1.customer_address ca,
        cassandra.keyspace_sf1.web_site ws,
        year,
        month,
        state
    WHERE 
        -- Constructing the start of the month and 60 days range
        CAST(d_date AS TIMESTAMP) BETWEEN 
            date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d')
            AND date_add('day', 60, date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d'))
        AND ws1.ws_ship_date_sk = d_date_sk
        AND ws1.ws_ship_addr_sk = ca_address_sk
        AND ca.ca_state = state.state
        AND ws1.ws_web_site_sk = ws.web_site_sk
        AND TRIM(ws.web_company_name) = 'pri'
        AND EXISTS (
            SELECT 1
            FROM postgresql.public.web_sales ws2
            WHERE ws1.ws_order_number = ws2.ws_order_number
              AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
        )
        AND NOT EXISTS (
            SELECT 1
            FROM cassandra.keyspace_sf1.web_returns wr1
            WHERE ws1.ws_order_number = wr1.wr_order_number
        )
  )

SELECT 
    "order count",
    "total shipping cost",
    "total net profit"
FROM sales_data
ORDER BY "order count"
LIMIT 100
