-- without joins

-- Define parameters
WITH params AS (
    SELECT 
        'CA' AS state,          -- Replace 'CA' with the desired state code
        FLOOR(1999 + RAND() * (2002 - 1999 + 1)) AS year
),
-- Calculate customer total return
customer_total_return AS (
    SELECT 
        wr_returning_customer_sk AS ctr_customer_sk,
        ca_state AS ctr_state,
        SUM(wr_return_amt) AS ctr_total_return
    FROM 
        web_returns,
        date_dim,
        customer_address,
        params
    WHERE 
        wr_returned_date_sk = d_date_sk
        AND d_year = params.year
        AND wr_returning_addr_sk = ca_address_sk
    GROUP BY 
        wr_returning_customer_sk, ca_state
)
-- Final Query
SELECT 
    c_customer_id,
    c_salutation,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date_sk,
    ctr_total_return
FROM 
    customer_total_return ctr1,
    customer_address,
    customer,
    params
WHERE 
    ctr1.ctr_total_return > (
        SELECT AVG(ctr_total_return) * 1.2
        FROM customer_total_return ctr2 
        WHERE ctr1.ctr_state = ctr2.ctr_state
    )
    AND ca_address_sk = c_current_addr_sk
    AND ca_state = params.state
    AND ctr1.ctr_customer_sk = c_customer_sk
ORDER BY 
    c_customer_id,
    c_salutation,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date_sk,
    ctr_total_return
LIMIT 100; -- Final limit
