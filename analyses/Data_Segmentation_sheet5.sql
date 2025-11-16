/* Data segmentation to check correlation
[Measure] by [Measure]
Example: Total products By Sales Range
Total Customers By Age */

-- case when statement can be used to segment based on conditions

/* the task is to segment the products in their cost range and count the number of products
that fall into each range */

SELECT 
product_key,
product_name,
product_cost,

CASE WHEN product_cost < 100 THEN 'Below 100'
     WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM gold.dim_products 

-- Step 2: aggregating the segmented data
WITH product_segment AS (
SELECT 
product_key,
product_name,
product_cost,

CASE WHEN product_cost < 100 THEN 'Below 100'
     WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM gold.dim_products ) 

SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC

/* Group customers into 3 segments based on spending behaviour and find the total number of customers by each group: 
- VIP: with 12 months of history and spending more than £5000
- Regular: Customers with 12 months of history spending £5000 or less
- New: Customers with less than 12 months of history 
*/

-- Step 1: collect the data you need to perform this analysis to get hang of all the variables needed to segment 

SELECT c.customer_key,
f.sales_amount,
f.order_date
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key

-- Step 2: Find the lifespan. the time between 1st order and last order
SELECT c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key

-- Step 3: segmented with new dimension 

WITH customer_spending AS (

SELECT c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
     ELSE 'New'
END customer_segment
FROM customer_spending


-- Step4: find the total number of customers for each segmented category
WITH customer_spending AS (

SELECT c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM(
    SELECT
    customer_key,
    CASE WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP'
         WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
         ELSE 'New'
    END customer_segment
    FROM customer_spending ) t 
GROUP BY customer_segment 
ORDER BY total_customers DESC


