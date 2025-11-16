/* Product Report

This report consolidates key product metrics and behaviours. 

1. Gathers identifying fields such as product name, category , subcategory and cost.
2. Segments products by revenue to identify high performers, mid, and low performers.
3. Aggregates product-level metrics:
    - total orders
    - total sales
    - total quantity sold 
    - total customers (unique)
    -lifespan (in months) 
4. Key performance metrics:
    - Recency (months since last sale)
    - Avg order revenue
    - Avg monthly revenue 
*/

SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.sales_quantity,
p.product_number,
p.product_name,
p.product_line,
p.category,
p.sub_category,
p.product_cost

FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON p.product_number = f.product_number
WHERE order_date IS NOT NULL


/* Step 2: Wrapping the above queries into a CTE for the base query*/

WITH base_query AS (
    SELECT 
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.sales_quantity,
    p.product_number,
    p.product_name,
    p.product_line,
    p.category,
    p.sub_category,
    p.product_cost

    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p 
    ON p.product_number = f.product_number
    WHERE order_date IS NOT NULL
),

product_aggregators AS (
SELECT 
    product_number,
    product_name,
    category,
    sub_category,
    product_cost,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
    MAX(order_date) AS last_sales_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
    ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(sales_quantity,0)),1) AS avg_selling_price

FROM base_query
GROUP BY 
    product_number,
    product_name,
    sub_category,
    category,
    product_cost
)

SELECT
    product_number,
    product_name,
    sub_category,
    category,
    product_cost,
    last_sales_date,
    DATEDIFF(month,last_sales_date, GETDATE()) AS recency_in_months,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >=10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- aov
    CASE WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_revenue,

    -- AVG MONTHLY REVENUE
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan 
    END AS avg_monthly_revenue

FROM product_aggregators

/* create view */
CREATE VIEW gold.report_products AS
WITH base_query AS (
    SELECT 
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.sales_quantity,
    p.product_number,
    p.product_name,
    p.product_line,
    p.category,
    p.sub_category,
    p.product_cost

    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p 
    ON p.product_number = f.product_number
    WHERE order_date IS NOT NULL
),

product_aggregators AS (
SELECT 
    product_number,
    product_name,
    category,
    sub_category,
    product_cost,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
    MAX(order_date) AS last_sales_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
    ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(sales_quantity,0)),1) AS avg_selling_price

FROM base_query
GROUP BY 
    product_number,
    product_name,
    sub_category,
    category,
    product_cost
)

SELECT
    product_number,
    product_name,
    sub_category,
    category,
    product_cost,
    last_sales_date,
    DATEDIFF(month,last_sales_date, GETDATE()) AS recency_in_months,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >=10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- aov
    CASE WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_revenue,

    -- AVG MONTHLY REVENUE
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan 
    END AS avg_monthly_revenue

FROM product_aggregators
