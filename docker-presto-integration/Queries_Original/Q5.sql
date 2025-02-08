-- -- postgresql, cassandra ok
-- -- not to big
-- -- 2nd for cassandra
 
-- with ssr as
--  (select s_store_id,
--        sum(sales_price) as sales,
--        sum(profit) as profit,
--        sum(return_amt) as returns,
--        sum(net_loss) as profit_loss
--  from
--   ( select  ss_store_sk as store_sk,
--            ss_sold_date_sk  as date_sk,
--            ss_ext_sales_price as sales_price,
--            ss_net_profit as profit,
--            cast(0 as decimal(7,2)) as return_amt,
--            cast(0 as decimal(7,2)) as net_loss
--     from store_sales
--     union all
--     select sr_store_sk as store_sk,
--           sr_returned_date_sk as date_sk,
--           cast(0 as decimal(7,2)) as sales_price,
--           cast(0 as decimal(7,2)) as profit,
--           sr_return_amt as return_amt,
--           sr_net_loss as net_loss
--     from store_returns
--    ) salesreturns,
--      date_dim,
--      store
--  where date_sk = d_date_sk
--        and DATE_TRUNC('day', d_date) between DATE_TRUNC('day', cast('1998-08-04' as date)) 
--                 and (DATE_TRUNC('day', cast('1998-08-04' as date)) + INTERVAL '14' DAY)
--        and store_sk = s_store_sk
--  group by s_store_id)
--  ,
--  csr as
--  (select cp_catalog_page_id,
--        sum(sales_price) as sales,
--        sum(profit) as profit,
--        sum(return_amt) as returns,
--        sum(net_loss) as profit_loss
--  from
--   ( select  cs_catalog_page_sk as page_sk,
--            cs_sold_date_sk  as date_sk,
--            cs_ext_sales_price as sales_price,
--            cs_net_profit as profit,
--            cast(0 as decimal(7,2)) as return_amt,
--            cast(0 as decimal(7,2)) as net_loss
--     from catalog_sales
--     union all
--     select cr_catalog_page_sk as page_sk,
--           cr_returned_date_sk as date_sk,
--           cast(0 as decimal(7,2)) as sales_price,
--           cast(0 as decimal(7,2)) as profit,
--           cr_return_amount as return_amt,
--           cr_net_loss as net_loss
--     from catalog_returns
--    ) salesreturns,
--      date_dim,
--      catalog_page
--  where date_sk = d_date_sk
--        and DATE_TRUNC('day', d_date) between DATE_TRUNC('day', cast('1998-08-04' as date))
--                 and (DATE_TRUNC('day', cast('1998-08-04' as date)) + INTERVAL '14' DAY)
--        and page_sk = cp_catalog_page_sk
--  group by cp_catalog_page_id)
--  ,
--  wsr as
--  (select web_site_id,
--        sum(sales_price) as sales,
--        sum(profit) as profit,
--        sum(return_amt) as returns,
--        sum(net_loss) as profit_loss
--  from
--   ( select  ws_web_site_sk as wsr_web_site_sk,
--            ws_sold_date_sk  as date_sk,
--            ws_ext_sales_price as sales_price,
--            ws_net_profit as profit,
--            cast(0 as decimal(7,2)) as return_amt,
--            cast(0 as decimal(7,2)) as net_loss
--     from web_sales
--     union all
--     select ws_web_site_sk as wsr_web_site_sk,
--           wr_returned_date_sk as date_sk,
--           cast(0 as decimal(7,2)) as sales_price,
--           cast(0 as decimal(7,2)) as profit,
--           wr_return_amt as return_amt,
--           wr_net_loss as net_loss
--     from web_returns left outer join web_sales on
--         ( wr_item_sk = ws_item_sk
--           and wr_order_number = ws_order_number)
--    ) salesreturns,
--      date_dim,
--      web_site
--  where date_sk = d_date_sk
--        and DATE_TRUNC('day', d_date) between DATE_TRUNC('day', cast('1998-08-04' as date))
--                 and (DATE_TRUNC('day', cast('1998-08-04' as date)) + INTERVAL '14' DAY)
--        and wsr_web_site_sk = web_site_sk
--  group by web_site_id)
--   select  channel
--        , id
--        , sum(sales) as sales
--        , sum(returns) as returns
--        , sum(profit) as profit
--  from 
--  (select 'store channel' as channel
--        , 'store' || s_store_id as id
--        , sales
--        , returns
--        , (profit - profit_loss) as profit
--  from   ssr
--  union all
--  select 'catalog channel' as channel
--        , 'catalog_page' || cp_catalog_page_id as id
--        , sales
--        , returns
--        , (profit - profit_loss) as profit
--  from  csr
--  union all
--  select 'web channel' as channel
--        , 'web_site' || web_site_id as id
--        , sales
--        , returns
--        , (profit - profit_loss) as profit
--  from   wsr
--  ) x
--  group by rollup (channel, id)
--  order by channel
--         ,id
--  limit 100

 WITH ssr AS (
    SELECT s_store_id,
           SUM(sales_price) AS sales,
           SUM(profit) AS profit,
           SUM(return_amt) AS returns,
           SUM(net_loss) AS profit_loss
    FROM (
        SELECT ss_store_sk AS store_sk,
               ss_sold_date_sk AS date_sk,
               ss_ext_sales_price AS sales_price,
               ss_net_profit AS profit,
               CAST(0 AS decimal(7, 2)) AS return_amt,
               CAST(0 AS decimal(7, 2)) AS net_loss
        FROM store_sales
        UNION ALL
        SELECT sr_store_sk AS store_sk,
               sr_returned_date_sk AS date_sk,
               CAST(0 AS decimal(7, 2)) AS sales_price,
               CAST(0 AS decimal(7, 2)) AS profit,
               sr_return_amt AS return_amt,
               sr_net_loss AS net_loss
        FROM store_returns
    ) salesreturns,
    date_dim,
    store
    WHERE date_sk = d_date_sk
      AND DATE_TRUNC('day', CAST(d_date AS date)) BETWEEN DATE_TRUNC('day', CAST('1998-08-04' AS date))
                                                      AND DATE_TRUNC('day', CAST('1998-08-04' AS date)) + INTERVAL '14' DAY
      AND store_sk = s_store_sk
    GROUP BY s_store_id
),
csr AS (
    SELECT cp_catalog_page_id,
           SUM(sales_price) AS sales,
           SUM(profit) AS profit,
           SUM(return_amt) AS returns,
           SUM(net_loss) AS profit_loss
    FROM (
        SELECT cs_catalog_page_sk AS page_sk,
               cs_sold_date_sk AS date_sk,
               cs_ext_sales_price AS sales_price,
               cs_net_profit AS profit,
               CAST(0 AS decimal(7, 2)) AS return_amt,
               CAST(0 AS decimal(7, 2)) AS net_loss
        FROM catalog_sales
        UNION ALL
        SELECT cr_catalog_page_sk AS page_sk,
               cr_returned_date_sk AS date_sk,
               CAST(0 AS decimal(7, 2)) AS sales_price,
               CAST(0 AS decimal(7, 2)) AS profit,
               cr_return_amount AS return_amt,
               cr_net_loss AS net_loss
        FROM catalog_returns
    ) salesreturns,
    date_dim,
    catalog_page
    WHERE date_sk = d_date_sk
      AND DATE_TRUNC('day', CAST(d_date AS date)) BETWEEN DATE_TRUNC('day', CAST('1998-08-04' AS date))
                                                      AND DATE_TRUNC('day', CAST('1998-08-04' AS date)) + INTERVAL '14' DAY
      AND page_sk = cp_catalog_page_sk
    GROUP BY cp_catalog_page_id
),
wsr AS (
    SELECT web_site_id,
           SUM(sales_price) AS sales,
           SUM(profit) AS profit,
           SUM(return_amt) AS returns,
           SUM(net_loss) AS profit_loss
    FROM (
        SELECT ws_web_site_sk AS wsr_web_site_sk,
               ws_sold_date_sk AS date_sk,
               ws_ext_sales_price AS sales_price,
               ws_net_profit AS profit,
               CAST(0 AS decimal(7, 2)) AS return_amt,
               CAST(0 AS decimal(7, 2)) AS net_loss
        FROM web_sales
        UNION ALL
        SELECT ws_web_site_sk AS wsr_web_site_sk,
               wr_returned_date_sk AS date_sk,
               CAST(0 AS decimal(7, 2)) AS sales_price,
               CAST(0 AS decimal(7, 2)) AS profit,
               wr_return_amt AS return_amt,
               wr_net_loss AS net_loss
        FROM web_returns
        LEFT OUTER JOIN web_sales ON (wr_item_sk = ws_item_sk AND wr_order_number = ws_order_number)
    ) salesreturns,
    date_dim,
    web_site
    WHERE date_sk = d_date_sk
      AND DATE_TRUNC('day', CAST(d_date AS date)) BETWEEN DATE_TRUNC('day', CAST('1998-08-04' AS date))
                                                      AND DATE_TRUNC('day', CAST('1998-08-04' AS date)) + INTERVAL '14' DAY
      AND wsr_web_site_sk = web_site_sk
    GROUP BY web_site_id
)
SELECT channel,
       id,
       SUM(sales) AS sales,
       SUM(returns) AS returns,
       SUM(profit) AS profit
FROM (
    SELECT 'store channel' AS channel,
           'store' || s_store_id AS id,
           sales,
           returns,
           (profit - profit_loss) AS profit
    FROM ssr
    UNION ALL
    SELECT 'catalog channel' AS channel,
           'catalog_page' || cp_catalog_page_id AS id,
           sales,
           returns,
           (profit - profit_loss) AS profit
    FROM csr
    UNION ALL
    SELECT 'web channel' AS channel,
           'web_site' || web_site_id AS id,
           sales,
           returns,
           (profit - profit_loss) AS profit
    FROM wsr
) x
GROUP BY ROLLUP (channel, id)
ORDER BY channel, id
LIMIT 100