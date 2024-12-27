-- insert to mongodb

CREATE TABLE call_center AS
SELECT 
    cc_call_center_sk,
    CAST(cc_call_center_id AS VARCHAR) AS cc_call_center_id,
    cc_rec_start_date,
    cc_rec_end_date,
    cc_closed_date_sk,
    cc_open_date_sk,
    CAST(cc_name AS VARCHAR) AS cc_name,
    CAST(cc_class AS VARCHAR) AS cc_class,
    cc_employees,
    cc_sq_ft,
    CAST(cc_hours AS VARCHAR) AS cc_hours,
    CAST(cc_manager AS VARCHAR) AS cc_manager,
    cc_mkt_id,
    CAST(cc_mkt_class AS VARCHAR) AS cc_mkt_class,
    CAST(cc_mkt_desc AS VARCHAR) AS cc_mkt_desc,
    CAST(cc_market_manager AS VARCHAR) AS cc_market_manager,
    cc_division,
    CAST(cc_division_name AS VARCHAR) AS cc_division_name,
    cc_company,
    CAST(cc_company_name AS VARCHAR) AS cc_company_name,
    CAST(cc_street_number AS VARCHAR) AS cc_street_number,
    CAST(cc_street_name AS VARCHAR) AS cc_street_name,
    CAST(cc_street_type AS VARCHAR) AS cc_street_type,
    CAST(cc_suite_number AS VARCHAR) AS cc_suite_number,
    CAST(cc_city AS VARCHAR) AS cc_city,
    CAST(cc_county AS VARCHAR) AS cc_county,
    CAST(cc_state AS VARCHAR) AS cc_state,
    CAST(cc_zip AS VARCHAR) AS cc_zip,
    CAST(cc_country AS VARCHAR) AS cc_country,
    cc_gmt_offset,
    cc_tax_percentage
FROM tpcds.sf1.call_center;

CREATE TABLE catalog_page AS
SELECT 
    cp_catalog_page_sk,
    CAST(cp_catalog_page_id AS VARCHAR) AS cp_catalog_page_id,
    cp_start_date_sk,
    cp_end_date_sk,
    CAST(cp_department AS VARCHAR) AS cp_department,
    cp_catalog_number,
    cp_catalog_page_number,
    CAST(cp_description AS VARCHAR) AS cp_description,
    CAST(cp_type AS VARCHAR) AS cp_type
FROM tpcds.sf1.catalog_page;

CREATE TABLE catalog_returns AS SELECT * FROM tpcds.sf1.catalog_returns;

CREATE TABLE catalog_sales AS SELECT * FROM tpcds.sf1.catalog_sales;

CREATE TABLE customer AS
SELECT 
    c_customer_sk,
    CAST(c_customer_id AS VARCHAR) AS c_customer_id,
    c_current_cdemo_sk,
    c_current_hdemo_sk,
    c_current_addr_sk,
    c_first_shipto_date_sk,
    c_first_sales_date_sk,
    CAST(c_salutation AS VARCHAR) AS c_salutation,
    CAST(c_first_name AS VARCHAR) AS c_first_name,
    CAST(c_last_name AS VARCHAR) AS c_last_name,
    CAST(c_preferred_cust_flag AS VARCHAR) AS c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country, 
    CAST(c_login AS VARCHAR) AS c_login,
    CAST(c_email_address AS VARCHAR) AS c_email_address,
    c_last_review_date_sk
FROM tpcds.sf1.customer;

CREATE TABLE customer_address AS
SELECT 
    ca_address_sk,
    CAST(ca_address_id AS VARCHAR) AS ca_address_id,
    CAST(ca_street_number AS VARCHAR) AS ca_street_number,
    CAST(ca_street_name AS VARCHAR) AS ca_street_name,
    CAST(ca_street_type AS VARCHAR) AS ca_street_type,
    CAST(ca_suite_number AS VARCHAR) AS ca_suite_number,
    CAST(ca_city AS VARCHAR) AS ca_city,
    CAST(ca_county AS VARCHAR) AS ca_county,
    CAST(ca_state AS VARCHAR) AS ca_state,
    CAST(ca_zip AS VARCHAR) AS ca_zip,
    CAST(ca_country AS VARCHAR) AS ca_country,
    ca_gmt_offset,
    CAST(ca_location_type AS VARCHAR) AS ca_location_type
FROM tpcds.sf1.customer_address;

CREATE TABLE customer_demographics AS
SELECT 
    cd_demo_sk,
    CAST(cd_gender AS VARCHAR) AS cd_gender,
    CAST(cd_marital_status AS VARCHAR) AS cd_marital_status,
    CAST(cd_education_status AS VARCHAR) AS cd_education_status,
    cd_purchase_estimate,
    CAST(cd_credit_rating AS VARCHAR) AS cd_credit_rating,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
FROM tpcds.sf1.customer_demographics;

CREATE TABLE date_dim AS
SELECT 
    d_date_sk,
    CAST(d_date_id AS VARCHAR) AS d_date_id,
    d_date,
    d_month_seq,
    d_week_seq,
    d_quarter_seq,
    d_year,
    d_dow,
    d_moy,
    d_dom,
    d_qoy,
    d_fy_year,
    d_fy_quarter_seq,
    d_fy_week_seq,
    CAST(d_day_name AS VARCHAR) AS d_day_name,
    CAST(d_quarter_name AS VARCHAR) AS d_quarter_name,
    CAST(d_holiday AS VARCHAR) AS d_holiday,
    CAST(d_weekend AS VARCHAR) AS d_weekend,
    CAST(d_following_holiday AS VARCHAR) AS d_following_holiday,
    d_first_dom,
    d_last_dom,
    d_same_day_ly,
    d_same_day_lq,
    CAST(d_current_day AS VARCHAR) AS d_current_day,
    CAST(d_current_week AS VARCHAR) AS d_current_week,
    CAST(d_current_month AS VARCHAR) AS d_current_month,
    CAST(d_current_quarter AS VARCHAR) AS d_current_quarter,
    CAST(d_current_year AS VARCHAR) AS d_current_year
FROM tpcds.sf1.date_dim;

CREATE TABLE dbgen_version AS SELECT * FROM tpcds.sf1.dbgen_version;

CREATE TABLE household_demographics AS
SELECT 
    hd_demo_sk,
    hd_income_band_sk,
    CAST(hd_buy_potential AS VARCHAR) AS hd_buy_potential,
    hd_dep_count,
    hd_vehicle_count
FROM tpcds.sf1.household_demographics;

CREATE TABLE income_band AS SELECT * FROM tpcds.sf1.income_band;

CREATE TABLE inventory AS SELECT * FROM tpcds.sf1.inventory;

CREATE TABLE item AS
SELECT 
    i_item_sk,
    CAST(i_item_id AS VARCHAR) AS i_item_id,
    i_rec_start_date,
    i_rec_end_date,
    CAST(i_item_desc AS VARCHAR) AS i_item_desc,
    i_current_price,
    i_wholesale_cost,
    i_brand_id,
    CAST(i_brand AS VARCHAR) AS i_brand,
    i_class_id,
    CAST(i_class AS VARCHAR) AS i_class,
    i_category_id,
    CAST(i_category AS VARCHAR) AS i_category,
    i_manufact_id,
    CAST(i_manufact AS VARCHAR) AS i_manufact,
    CAST(i_size AS VARCHAR) AS i_size,
    CAST(i_formulation AS VARCHAR) AS i_formulation,
    CAST(i_color AS VARCHAR) AS i_color,
    CAST(i_units AS VARCHAR) AS i_units,
    CAST(i_container AS VARCHAR) AS i_container,
    i_manager_id,
    CAST(i_product_name AS VARCHAR) AS i_product_name
FROM tpcds.sf1.item;

CREATE TABLE promotion AS
SELECT 
    p_promo_sk,
    CAST(p_promo_id AS VARCHAR) AS p_promo_id,
    p_start_date_sk,
    p_end_date_sk,
    p_item_sk,
    p_cost,
    p_response_targe,
    CAST(p_promo_name AS VARCHAR) AS p_promo_name,
    CAST(p_channel_dmail AS VARCHAR) AS p_channel_dmail,
    CAST(p_channel_email AS VARCHAR) AS p_channel_email,
    CAST(p_channel_catalog AS VARCHAR) AS p_channel_catalog,
    CAST(p_channel_tv AS VARCHAR) AS p_channel_tv,
    CAST(p_channel_radio AS VARCHAR) AS p_channel_radio,
    CAST(p_channel_press AS VARCHAR) AS p_channel_press,
    CAST(p_channel_event AS VARCHAR) AS p_channel_event,
    CAST(p_channel_demo AS VARCHAR) AS p_channel_demo,
    CAST(p_channel_details AS VARCHAR) AS p_channel_details,
    CAST(p_purpose AS VARCHAR) AS p_purpose,
    CAST(p_discount_active AS VARCHAR) AS p_discount_active
FROM tpcds.sf1.promotion;

CREATE TABLE reason AS
SELECT 
    r_reason_sk,
    CAST(r_reason_id AS VARCHAR) AS r_reason_id,
    CAST(r_reason_desc AS VARCHAR) AS r_reason_desc
FROM tpcds.sf1.reason;

CREATE TABLE ship_mode AS
SELECT 
    sm_ship_mode_sk,
    CAST(sm_ship_mode_id AS VARCHAR) AS sm_ship_mode_id,
    CAST(sm_type AS VARCHAR) AS sm_type,
    CAST(sm_code AS VARCHAR) AS sm_code,
    CAST(sm_carrier AS VARCHAR) AS sm_carrier,
    CAST(sm_contract AS VARCHAR) AS sm_contract
FROM tpcds.sf1.ship_mode;

CREATE TABLE store AS
SELECT 
    s_store_sk,
    CAST(s_store_id AS VARCHAR) AS s_store_id,
    s_rec_start_date,
    s_rec_end_date,
    s_closed_date_sk,
    CAST(s_store_name AS VARCHAR) AS s_store_name,
    s_number_employees,
    s_floor_space,
    CAST(s_hours AS VARCHAR) AS s_hours,
    CAST(s_manager AS VARCHAR) AS s_manager,
    s_market_id,
    CAST(s_geography_class AS VARCHAR) AS s_geography_class,
    CAST(s_market_desc AS VARCHAR) AS s_market_desc,
    CAST(s_market_manager AS VARCHAR) AS s_market_manager,
    s_division_id,
    CAST(s_division_name AS VARCHAR) AS s_division_name,
    s_company_id,
    CAST(s_company_name AS VARCHAR) AS s_company_name,
    CAST(s_street_number AS VARCHAR) AS s_street_number,
    CAST(s_street_name AS VARCHAR) AS s_street_name,
    CAST(s_street_type AS VARCHAR) AS s_street_type,
    CAST(s_suite_number AS VARCHAR) AS s_suite_number,
    CAST(s_city AS VARCHAR) AS s_city,
    CAST(s_county AS VARCHAR) AS s_county,
    CAST(s_state AS VARCHAR) AS s_state,
    CAST(s_zip AS VARCHAR) AS s_zip,
    CAST(s_country AS VARCHAR) AS s_country,
    s_gmt_offset,
    s_tax_precentage
FROM tpcds.sf1.store;

CREATE TABLE store_returns AS SELECT * FROM tpcds.sf1.store_returns;

CREATE TABLE store_sales AS SELECT * FROM tpcds.sf1.store_sales;

CREATE TABLE time_dim AS
SELECT 
    t_time_sk,
    CAST(t_time_id AS VARCHAR) AS t_time_id,
    t_time,
    t_hour,
    t_minute,
    t_second,
    CAST(t_am_pm AS VARCHAR) AS t_am_pm,
    CAST(t_shift AS VARCHAR) AS t_shift,
    CAST(t_sub_shift AS VARCHAR) AS t_sub_shift,
    CAST(t_meal_time AS VARCHAR) AS t_meal_time
FROM tpcds.sf1.time_dim;

CREATE TABLE warehouse AS
SELECT 
    w_warehouse_sk,
    CAST(w_warehouse_id AS VARCHAR) AS w_warehouse_id,
    CAST(w_warehouse_name AS VARCHAR) AS w_warehouse_name,
    w_warehouse_sq_ft,
    CAST(w_street_number AS VARCHAR) AS w_street_number,
    CAST(w_street_name AS VARCHAR) AS w_street_name,
    CAST(w_street_type AS VARCHAR) AS w_street_type,
    CAST(w_suite_number AS VARCHAR) AS w_suite_number,
    CAST(w_city AS VARCHAR) AS w_city,
    CAST(w_county AS VARCHAR) AS w_county,
    CAST(w_state AS VARCHAR) AS w_state,
    CAST(w_zip AS VARCHAR) AS w_zip,
    CAST(w_country AS VARCHAR) AS w_country,
    w_gmt_offset
FROM tpcds.sf1.warehouse;

CREATE TABLE web_page AS
SELECT 
    wp_web_page_sk,
    CAST(wp_web_page_id AS VARCHAR) AS wp_web_page_id,
    wp_rec_start_date,
    wp_rec_end_date,
    wp_creation_date_sk,
    wp_access_date_sk,
    CAST(wp_autogen_flag AS VARCHAR) AS wp_autogen_flag,
    wp_customer_sk,
    wp_url,
    CAST(wp_type AS VARCHAR) AS wp_type,
    wp_char_count,
    wp_link_count,
    wp_image_count,
    wp_max_ad_count
FROM tpcds.sf1.web_page;

CREATE TABLE web_returns AS SELECT * FROM tpcds.sf1.web_returns;

CREATE TABLE web_sales AS SELECT * FROM tpcds.sf1.web_sales;

CREATE TABLE web_site AS
SELECT 
    web_site_sk,
    CAST(web_site_id AS VARCHAR) AS web_site_id,
    web_rec_start_date,
    web_rec_end_date,
    web_name,
    web_open_date_sk,
    web_close_date_sk,
    web_class,
    web_manager,
    web_mkt_id,
    web_mkt_class,
    web_mkt_desc,
    web_market_manager,
    web_company_id,
    CAST(web_company_name AS VARCHAR) AS web_company_name,
    CAST(web_street_number AS VARCHAR) AS web_street_number,
    web_street_name,
    CAST(web_street_type AS VARCHAR) AS web_street_type,
    CAST(web_suite_number AS VARCHAR) AS web_suite_number,
    web_city,
    web_county,
    CAST(web_state AS VARCHAR) AS web_state,
    CAST(web_zip AS VARCHAR) AS web_zip,
    web_country,
    web_gmt_offset,
    web_tax_percentage
FROM tpcds.sf1.web_site;
