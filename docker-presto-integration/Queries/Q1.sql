-- postgresql,cassandra ok

WITH customer_total_return AS (
    SELECT 
        sr_customer_sk AS ctr_customer_sk,
        sr_store_sk AS ctr_store_sk,
        SUM(sr_fee) AS ctr_total_return
    FROM 
        store_returns
    JOIN 
        date_dim ON sr_returned_date_sk = d_date_sk
    WHERE 
        d_year = 2000
    GROUP BY 
        sr_customer_sk, sr_store_sk
)
SELECT 
    c_customer_id
FROM 
    customer_total_return ctr1,
    store s,
    customer c
WHERE 
    s.s_store_sk = ctr1.ctr_store_sk
    AND ctr1.ctr_customer_sk = c.c_customer_sk
    AND ctr1.ctr_total_return > (
        SELECT 
            AVG(ctr_total_return) * 1.2
        FROM 
            customer_total_return ctr2
        WHERE 
            ctr1.ctr_store_sk = ctr2.ctr_store_sk
    )
    AND s.s_state = 'TN'
ORDER BY 
    c_customer_id
LIMIT 100
