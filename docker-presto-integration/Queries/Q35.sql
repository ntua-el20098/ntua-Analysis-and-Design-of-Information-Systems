-- postgresql,cassandra ok

-- Define parameters
WITH customer_sales AS (
    SELECT 
        ca_state,
        cd_gender,
        cd_marital_status,
        cd_dep_count,
        COUNT(*) AS cnt1,
        SUM(CASE WHEN cd_dep_count IS NOT NULL THEN cd_dep_count ELSE 0 END) AS sum_cd_dep_count,  -- AGGONE for cd_dep_count
        MIN(CASE WHEN cd_dep_count IS NOT NULL THEN cd_dep_count ELSE NULL END) AS min_cd_dep_count,  -- AGGTWO for cd_dep_count
        MAX(CASE WHEN cd_dep_count IS NOT NULL THEN cd_dep_count ELSE NULL END) AS max_cd_dep_count,  -- AGGTHREE for cd_dep_count
        cd_dep_employed_count,
        COUNT(*) AS cnt2,
        SUM(CASE WHEN cd_dep_employed_count IS NOT NULL THEN cd_dep_employed_count ELSE 0 END) AS sum_cd_dep_employed_count,  -- AGGONE for cd_dep_employed_count
        MIN(CASE WHEN cd_dep_employed_count IS NOT NULL THEN cd_dep_employed_count ELSE NULL END) AS min_cd_dep_employed_count,  -- AGGTWO for cd_dep_employed_count
        MAX(CASE WHEN cd_dep_employed_count IS NOT NULL THEN cd_dep_employed_count ELSE NULL END) AS max_cd_dep_employed_count,  -- AGGTHREE for cd_dep_employed_count
        cd_dep_college_count,
        COUNT(*) AS cnt3,
        SUM(CASE WHEN cd_dep_college_count IS NOT NULL THEN cd_dep_college_count ELSE 0 END) AS sum_cd_dep_college_count,  -- AGGONE for cd_dep_college_count
        MIN(CASE WHEN cd_dep_college_count IS NOT NULL THEN cd_dep_college_count ELSE NULL END) AS min_cd_dep_college_count,  -- AGGTWO for cd_dep_college_count
        MAX(CASE WHEN cd_dep_college_count IS NOT NULL THEN cd_dep_college_count ELSE NULL END) AS max_cd_dep_college_count  -- AGGTHREE for cd_dep_college_count
    FROM 
        cassandra.keyspace_sf1.customer c, cassandra.keyspace_sf1.customer_address ca, postgresql.public.customer_demographics cd
    WHERE 
        c.c_current_addr_sk = ca.ca_address_sk 
        AND cd.cd_demo_sk = c.c_current_cdemo_sk
        AND EXISTS (
            SELECT 1
            FROM postgresql.public.store_sales ss, postgresql.public.date_dim d1
            WHERE ss.ss_customer_sk = c.c_customer_sk
              AND ss.ss_sold_date_sk = d1.d_date_sk
              AND d1.d_year = 2000  -- Replaced YEAR with 2000
              AND d1.d_qoy < 4
        )
        AND EXISTS (
            SELECT 1
            FROM postgresql.public.web_sales ws, postgresql.public.date_dim d2
            WHERE ws.ws_bill_customer_sk = c.c_customer_sk
              AND ws.ws_sold_date_sk = d2.d_date_sk
              AND d2.d_year = 2000  -- Replaced YEAR with 2000
              AND d2.d_qoy < 4
        )
        AND EXISTS (
            SELECT 1
            FROM mongodb.sf1.catalog_sales cs, postgresql.public.date_dim d3
            WHERE cs.cs_ship_customer_sk = c.c_customer_sk
              AND cs.cs_sold_date_sk = d3.d_date_sk
              AND d3.d_year = 2000  -- Replaced YEAR with 2000
              AND d3.d_qoy < 4
        )
    GROUP BY 
        ca.ca_state,
        cd.cd_gender,
        cd.cd_marital_status,
        cd.cd_dep_count,
        cd.cd_dep_employed_count,
        cd.cd_dep_college_count
)

SELECT 
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cnt1,
    sum_cd_dep_count,
    min_cd_dep_count,
    max_cd_dep_count,
    cd_dep_employed_count,
    cnt2,
    sum_cd_dep_employed_count,
    min_cd_dep_employed_count,
    max_cd_dep_employed_count,
    cd_dep_college_count,
    cnt3,
    sum_cd_dep_college_count,
    min_cd_dep_college_count,
    max_cd_dep_college_count
FROM 
    customer_sales
ORDER BY 
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
LIMIT 100 -- Apply the limit
