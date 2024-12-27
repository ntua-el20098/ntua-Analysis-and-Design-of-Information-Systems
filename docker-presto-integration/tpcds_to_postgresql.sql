-- insert to postgresql

-- Set schema name
SET schema_name = 'sf1';

CREATE TABLE call_center AS SELECT * FROM tpcds.sf1.call_center;
CREATE TABLE catalog_page AS SELECT * FROM tpcds.sf1.catalog_page;
CREATE TABLE catalog_returns AS SELECT * FROM tpcds.sf1.catalog_returns;
CREATE TABLE catalog_sales AS SELECT * FROM tpcds.sf1.catalog_sales;
CREATE TABLE customer AS SELECT * FROM tpcds.sf1.customer;
CREATE TABLE customer_address AS SELECT * FROM tpcds.sf1.customer_address;
CREATE TABLE customer_demographics AS SELECT * FROM tpcds.sf1.customer_demographics;
CREATE TABLE date_dim AS SELECT * FROM tpcds.sf1.date_dim;
CREATE TABLE postgresql.public.dbgen_version AS 
SELECT 
    dv_version,
    dv_create_date,
    CAST(dv_create_time AS VARCHAR) AS dv_create_time,  -- Cast dv_create_time (TIME) to VARCHAR
    dv_cmdline_args
FROM tpcds.sf1.dbgen_version;

CREATE TABLE household_demographics AS SELECT * FROM tpcds.sf1.household_demographics;
CREATE TABLE income_band AS SELECT * FROM tpcds.sf1.income_band;
CREATE TABLE inventory AS SELECT * FROM tpcds.sf1.inventory;
CREATE TABLE item AS SELECT * FROM tpcds.sf1.item;
CREATE TABLE promotion AS SELECT * FROM tpcds.sf1.promotion;
CREATE TABLE reason AS SELECT * FROM tpcds.sf1.reason;
CREATE TABLE ship_mode AS SELECT * FROM tpcds.sf1.ship_mode;
CREATE TABLE store AS SELECT * FROM tpcds.sf1.store;
CREATE TABLE store_returns AS SELECT * FROM tpcds.sf1.store_returns;
CREATE TABLE store_sales AS SELECT * FROM tpcds.sf1.store_sales;
CREATE TABLE time_dim AS SELECT * FROM tpcds.sf1.time_dim;
CREATE TABLE warehouse AS SELECT * FROM tpcds.sf1.warehouse;
CREATE TABLE web_page AS SELECT * FROM tpcds.sf1.web_page;
CREATE TABLE web_returns AS SELECT * FROM tpcds.sf1.web_returns;
CREATE TABLE web_sales AS SELECT * FROM tpcds.sf1.web_sales;
CREATE TABLE web_site AS SELECT * FROM tpcds.sf1.web_site;