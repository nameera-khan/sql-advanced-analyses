/* 
CUSTOMER REPORT

This report consolidates customer behaviour and metrics as follows: 

1. Gathers identifying fields such as names, age, transaction details etc.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level transaction metrics:
    - total orders
    - total sales
    - total quantity purchased 
    - total products 
    - customer retention span (lifespan of customer's transactions)
4. Key performance metrics:
    - Recency (months since last order)
    - Avg order value
    - Avg monthly spend 
*/
-- The intermediate table that consists of data from the fact and dimension table will be joined using CTEs
-- The CTE will include transformations from the fact and dim table 

/* Step 1: Retrieve core columns from tables */


SELECT 
f.order_number,
f.product_number, 
f.order_date,
f.sales_amount,
f.sales_quantity,
c.customer_key,
c.customer_number,
-- TRANSFORMING THE CUSTOMER NAMES INTO ONE COLUMN USING CONCAT
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
-- CREATING AGE GROUPS INSTEAD OF BIRTHDATES 
DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age,
c.birthdate
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL

/* Step 2: Wrapping the above queries into a CTE for the base query*/

WITH base_query AS (

SELECT 
f.order_number,
f.product_number, 
f.order_date,
f.sales_amount,
f.sales_quantity,
c.customer_key,
c.customer_number,
-- TRANSFORMING THE CUSTOMER NAMES INTO ONE COLUMN USING CONCAT
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
-- CREATING AGE GROUPS INSTEAD OF BIRTHDATES 
DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age,
c.birthdate
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL

)
SELECT 
* FROM base_query

/* STEP 3: AGGREGATORS */

WITH base_query AS (

    SELECT 
    f.order_number,
    f.product_number, 
    f.order_date,
    f.sales_amount,
    f.sales_quantity,
    c.customer_key,
    c.customer_number,
    -- TRANSFORMING THE CUSTOMER NAMES INTO ONE COLUMN USING CONCAT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -- CREATING AGE GROUPS INSTEAD OF BIRTHDATES 
    DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age,
    c.birthdate
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c 
    ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL

)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,

    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
    COUNT(DISTINCT product_number) AS total_products, 
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan


FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    customer_age

/* Final KPIs from aggregations */

/* Step 5 : segmenting customers and creating KPIs */

WITH base_query AS (

    SELECT 
    f.order_number,
    f.product_number, 
    f.order_date,
    f.sales_amount,
    f.sales_quantity,
    c.customer_key,
    c.customer_number,
    -- TRANSFORMING THE CUSTOMER NAMES INTO ONE COLUMN USING CONCAT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -- CREATING AGE GROUPS INSTEAD OF BIRTHDATES 
    DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age,
    c.birthdate
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c 
    ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL

),

customer_aggregation AS (

/* Customer Aggregations : To summarise key metrics at customer level */
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,

    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
    COUNT(DISTINCT product_number) AS total_products, 
    MAX(order_date) AS last_order_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan

FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    customer_age
)

SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    CASE WHEN customer_age < 20 THEN 'Under 20'
         WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
         WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
         WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,
    CASE 
            WHEN lifespan >=12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan >=12 AND total_sales <=5000 THEN 'Regular'
            ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    
    -- Compute avg order value
    CASE WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_val,

    -- Compute avg monthly spend
    CASE WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

    
FROM customer_aggregation
------------------------------------------------------------------------------------

/* CREATE A VIEW FOR DATA ANALYSTS TO BE ABLE TO CREATE DASHBOARDS USING THE REPORT

- This can be done by wrapping the Final KPIs query into a CREATE VIEW query

*/
CREATE VIEW gold.report_customers AS 
WITH base_query AS (

    SELECT 
    f.order_number,
    f.product_number, 
    f.order_date,
    f.sales_amount,
    f.sales_quantity,
    c.customer_key,
    c.customer_number,
    -- TRANSFORMING THE CUSTOMER NAMES INTO ONE COLUMN USING CONCAT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -- CREATING AGE GROUPS INSTEAD OF BIRTHDATES 
    DATEDIFF(year, c.birthdate, GETDATE()) AS customer_age,
    c.birthdate
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c 
    ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL

),

customer_aggregation AS (

/* Customer Aggregations : To summarise key metrics at customer level */
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,

    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
    COUNT(DISTINCT product_number) AS total_products, 
    MAX(order_date) AS last_order_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan

FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    customer_age
)

SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    CASE WHEN customer_age < 20 THEN 'Under 20'
         WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
         WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
         WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,
    CASE 
            WHEN lifespan >=12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan >=12 AND total_sales <=5000 THEN 'Regular'
            ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    
    -- Compute avg order value
    CASE WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_val,

    -- Compute avg monthly spend
    CASE WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

    
FROM customer_aggregation

