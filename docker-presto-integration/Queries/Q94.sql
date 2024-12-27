--without join

WITH 
  -- Defining the YEAR, MONTH, and STATE variables
  year AS (SELECT CAST(FLOOR(1 + (RAND() * 4)) + 1998 AS INTEGER) AS year),
  month AS (SELECT CAST(FLOOR(2 + (RAND() * 4)) AS INTEGER) AS month),
  state AS (SELECT 'CA' AS state),  -- Static value for STATE (e.g., 'CA' for California)

  sales_data AS (
    SELECT 
        COUNT(DISTINCT ws1.ws_order_number) AS "order count",
        SUM(ws1.ws_ext_ship_cost) AS "total shipping cost",
        SUM(ws1.ws_net_profit) AS "total net profit"
    FROM 
        web_sales ws1,
        date_dim,
        customer_address ca,
        web_site ws,
        year,
        month,
        state
    WHERE 
        -- Constructing the start of the month and 60 days range
        d_date BETWEEN 
            date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d')
            AND date_add('day', 60, date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d'))
        AND ws1.ws_ship_date_sk = d_date_sk
        AND ws1.ws_ship_addr_sk = ca_address_sk
        AND ca.ca_state = state.state
        AND ws1.ws_web_site_sk = ws.web_site_sk
        AND ws.web_company_name = 'pri'
        AND EXISTS (
            SELECT 1
            FROM web_sales ws2
            WHERE ws1.ws_order_number = ws2.ws_order_number
              AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
        )
        AND NOT EXISTS (
            SELECT 1
            FROM web_returns wr1
            WHERE ws1.ws_order_number = wr1.wr_order_number
        )
  )

SELECT 
    "order count",
    "total shipping cost",
    "total net profit"
FROM sales_data
ORDER BY "order count"
LIMIT 100;

-- with join

WITH 
  -- Defining the YEAR, MONTH, and STATE variables
  year AS (SELECT CAST(FLOOR(1 + (RAND() * 4)) + 1998 AS INTEGER) AS year),
  month AS (SELECT CAST(FLOOR(2 + (RAND() * 4)) AS INTEGER) AS month),
  state AS (SELECT 'CA' AS state),  -- Static value for STATE (e.g., 'CA' for California)

  sales_data AS (
    SELECT 
        COUNT(DISTINCT ws1.ws_order_number) AS "order count",
        SUM(ws1.ws_ext_ship_cost) AS "total shipping cost",
        SUM(ws1.ws_net_profit) AS "total net profit"
    FROM 
        web_sales ws1
    JOIN 
        date_dim dd ON ws1.ws_ship_date_sk = dd.d_date_sk
    JOIN 
        customer_address ca ON ws1.ws_ship_addr_sk = ca.ca_address_sk
    JOIN 
        web_site ws ON ws1.ws_web_site_sk = ws.web_site_sk
    CROSS JOIN 
        year, month, state  -- Ensure the YEAR, MONTH, and STATE are part of the query context
    WHERE 
        -- Constructing the start of the month and 60 days range
        dd.d_date BETWEEN 
            date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d')
            AND date_add('day', 60, date_parse(CONCAT(CAST(year.year AS VARCHAR), '-', LPAD(CAST(month.month AS VARCHAR), 2, '0'), '-01'), '%Y-%m-%d'))
        AND ca.ca_state = state.state
        AND ws.web_company_name = 'pri'
        AND EXISTS (
            SELECT 1
            FROM web_sales ws2
            WHERE ws1.ws_order_number = ws2.ws_order_number
              AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
        )
        AND NOT EXISTS (
            SELECT 1
            FROM web_returns wr1
            WHERE ws1.ws_order_number = wr1.wr_order_number
        )
  )

SELECT 
    "order count",
    "total shipping cost",
    "total net profit"
FROM sales_data
ORDER BY "order count"
LIMIT 100;
