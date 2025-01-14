-- postgresql,cassandra ok

-- Define parameters dynamically before query execution:
WITH customer_sales AS (
    SELECT 
        ca_zip,
        SUM(cs_sales_price) AS total_sales
    FROM 
        mongodb.sf1.catalog_sales cs, 
        cassandra.keyspace_sf1.customer c, 
        cassandra.keyspace_sf1.customer_address ca, 
        postgresql.public.date_dim d
    WHERE 
        cs.cs_bill_customer_sk = c.c_customer_sk 
        AND c.c_current_addr_sk = ca.ca_address_sk 
        AND cs.cs_sold_date_sk = d.d_date_sk
        AND (
            -- Filter by ZIP code or State or sales price greater than 500
            substr(ca.ca_zip, 1, 5) IN ('85669', '86197', '88274', '83405', '86475', 
                                        '85392', '85460', '80348', '81792') 
            OR ca.ca_state IN ('CA', 'WA', 'GA') 
            OR cs.cs_sales_price > 500
        )
        AND d.d_qoy = 1  -- Replace 1 with the actual value of QOY you want
        AND d.d_year = 2000  -- Replace 2000 with the actual YEAR you want
    GROUP BY 
        ca.ca_zip
)

-- _LIMITA: Apply the LIMIT for the main SELECT query scope
SELECT 
    ca_zip, 
    total_sales
FROM 
    customer_sales
ORDER BY 
    ca_zip
-- _LIMITC: Final row limit for the query
LIMIT 100
