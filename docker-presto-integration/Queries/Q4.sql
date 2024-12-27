WITH params AS (
    -- Define the YEAR value directly (example: 1999)
    SELECT 1999 AS year, -- You can change this to any value you need
           100 AS limit_count -- Static limit value
),
year_total AS (
    -- Sales from store_sales
    SELECT c_customer_id AS customer_id,
           c_first_name AS customer_first_name,
           c_last_name AS customer_last_name,
           c_preferred_cust_flag AS customer_preferred_cust_flag,
           c_birth_country AS customer_birth_country,
           c_login AS customer_login,
           c_email_address AS customer_email_address,
           d_year AS dyear,
           SUM(((ss_ext_list_price - ss_ext_wholesale_cost - ss_ext_discount_amt) + ss_ext_sales_price) / 2) AS year_total,
           's' AS sale_type
    FROM customer
    CROSS JOIN store_sales ss
    CROSS JOIN date_dim d
    CROSS JOIN params p
    WHERE c_customer_sk = ss_customer_sk
      AND ss_sold_date_sk = d_date_sk
      AND d.d_year = p.year
    GROUP BY c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country, c_login, c_email_address, d_year

    UNION ALL

    -- Sales from catalog_sales
    SELECT c_customer_id AS customer_id,
           c_first_name AS customer_first_name,
           c_last_name AS customer_last_name,
           c_preferred_cust_flag AS customer_preferred_cust_flag,
           c_birth_country AS customer_birth_country,
           c_login AS customer_login,
           c_email_address AS customer_email_address,
           d_year AS dyear,
           SUM(((cs_ext_list_price - cs_ext_wholesale_cost - cs_ext_discount_amt) + cs_ext_sales_price) / 2) AS year_total,
           'c' AS sale_type
    FROM customer
    CROSS JOIN catalog_sales cs
    CROSS JOIN date_dim d
    CROSS JOIN params p
    WHERE c_customer_sk = cs_bill_customer_sk
      AND cs_sold_date_sk = d_date_sk
      AND d.d_year = p.year
    GROUP BY c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country, c_login, c_email_address, d_year

    UNION ALL

    -- Sales from web_sales
    SELECT c_customer_id AS customer_id,
           c_first_name AS customer_first_name,
           c_last_name AS customer_last_name,
           c_preferred_cust_flag AS customer_preferred_cust_flag,
           c_birth_country AS customer_birth_country,
           c_login AS customer_login,
           c_email_address AS customer_email_address,
           d_year AS dyear,
           SUM(((ws_ext_list_price - ws_ext_wholesale_cost - ws_ext_discount_amt) + ws_ext_sales_price) / 2) AS year_total,
           'w' AS sale_type
    FROM customer
    CROSS JOIN web_sales ws
    CROSS JOIN date_dim d
    CROSS JOIN params p
    WHERE c_customer_sk = ws_bill_customer_sk
      AND ws_sold_date_sk = d_date_sk
      AND d.d_year = p.year
    GROUP BY c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country, c_login, c_email_address, d_year
),
final_result AS (
    SELECT t_s_secyear.customer_id,
           t_s_secyear.customer_first_name,
           t_s_secyear.customer_last_name,
           t_s_secyear.customer_preferred_cust_flag,
           t_s_secyear.customer_birth_country,
           t_s_secyear.customer_login,
           t_s_secyear.customer_email_address,
           t_s_secyear.dyear,
           t_s_secyear.year_total AS s_year_total,
           t_c_secyear.year_total AS c_year_total,
           t_w_secyear.year_total AS w_year_total,
           t_s_firstyear.year_total AS s_firstyear_total,
           t_c_firstyear.year_total AS c_firstyear_total,
           t_w_firstyear.year_total AS w_firstyear_total
    FROM year_total t_s_firstyear
    CROSS JOIN year_total t_s_secyear
    CROSS JOIN year_total t_c_firstyear
    CROSS JOIN year_total t_c_secyear
    CROSS JOIN year_total t_w_firstyear
    CROSS JOIN year_total t_w_secyear
    CROSS JOIN params p
    WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
      AND t_s_secyear.customer_id = t_c_secyear.customer_id
      AND t_s_secyear.customer_id = t_c_firstyear.customer_id
      AND t_s_secyear.customer_id = t_w_firstyear.customer_id
      AND t_s_secyear.customer_id = t_w_secyear.customer_id
      AND t_s_firstyear.sale_type = 's'
      AND t_c_firstyear.sale_type = 'c'
      AND t_w_firstyear.sale_type = 'w'
      AND t_s_secyear.sale_type = 's'
      AND t_c_secyear.sale_type = 'c'
      AND t_w_secyear.sale_type = 'w'
      AND t_s_firstyear.dyear = p.year
      AND t_s_secyear.dyear = p.year + 1
      AND t_c_firstyear.dyear = p.year
      AND t_c_secyear.dyear = p.year + 1
      AND t_w_firstyear.dyear = p.year
      AND t_w_secyear.dyear = p.year + 1
      AND t_s_firstyear.year_total > 0
      AND t_c_firstyear.year_total > 0
      AND t_w_firstyear.year_total > 0
      AND CASE WHEN t_c_firstyear.year_total > 0 THEN t_c_secyear.year_total / t_c_firstyear.year_total ELSE NULL END
           > CASE WHEN t_s_firstyear.year_total > 0 THEN t_s_secyear.year_total / t_s_firstyear.year_total ELSE NULL END
      AND CASE WHEN t_c_firstyear.year_total > 0 THEN t_c_secyear.year_total / t_c_firstyear.year_total ELSE NULL END
           > CASE WHEN t_w_firstyear.year_total > 0 THEN t_w_secyear.year_total / t_w_firstyear.year_total ELSE NULL END
)
SELECT *
FROM final_result
ORDER BY customer_id, customer_first_name, customer_last_name
LIMIT 100;
