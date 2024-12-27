-- Define dynamic parameters (replaced with actual values)
WITH customer_sales AS (
    SELECT 
        i.i_item_desc,
        w.w_warehouse_name,
        d1.d_week_seq,
        SUM(CASE WHEN p.p_promo_sk IS NULL THEN 1 ELSE 0 END) AS no_promo,
        SUM(CASE WHEN p.p_promo_sk IS NOT NULL THEN 1 ELSE 0 END) AS promo,
        COUNT(*) AS total_cnt
    FROM 
        catalog_sales cs
    JOIN 
        inventory inv ON cs.cs_item_sk = inv.inv_item_sk
    JOIN 
        warehouse w ON w.w_warehouse_sk = inv.inv_warehouse_sk
    JOIN 
        item i ON i.i_item_sk = cs.cs_item_sk
    JOIN 
        customer_demographics cd ON cs.cs_bill_cdemo_sk = cd.cd_demo_sk
    JOIN 
        household_demographics hd ON cs.cs_bill_hdemo_sk = hd.hd_demo_sk
    JOIN 
        date_dim d1 ON cs.cs_sold_date_sk = d1.d_date_sk
    JOIN 
        date_dim d2 ON inv.inv_date_sk = d2.d_date_sk
    JOIN 
        date_dim d3 ON cs.cs_ship_date_sk = d3.d_date_sk
    LEFT JOIN 
        promotion p ON cs.cs_promo_sk = p.p_promo_sk
    LEFT JOIN 
        catalog_returns cr ON cr.cr_item_sk = cs.cs_item_sk AND cr.cr_order_number = cs.cs_order_number
    WHERE 
        d1.d_week_seq = d2.d_week_seq
        AND inv.inv_quantity_on_hand < cs.cs_quantity
        AND d3.d_date > DATE_ADD('day', 5, d1.d_date)  -- Fixed date addition
        AND hd.hd_buy_potential = '1001-5000'  -- Replaced [BP] with '1001-5000'
        AND d1.d_year = 2000                    -- Replaced [YEAR] with 2000
        AND cd.cd_marital_status = 'M'          -- Replaced [MS] with 'M'
    GROUP BY 
        i.i_item_desc,
        w.w_warehouse_name,
        d1.d_week_seq
)

-- Apply the limit and order the result
SELECT 
    i_item_desc,
    w_warehouse_name,
    d_week_seq,
    no_promo,
    promo,
    total_cnt
FROM 
    customer_sales
ORDER BY 
    total_cnt DESC, 
    i_item_desc, 
    w_warehouse_name, 
    d_week_seq
LIMIT 100; -- Replace [_LIMITC] with actual limit
