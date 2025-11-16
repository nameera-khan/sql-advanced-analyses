/* To Analyse yearly performance of products by comparing sales to avg sales performance of the product and the previous year's sales */
-- USING CTE 
WITH yearly_product_sales AS 
(
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f 
-- THE PRODUCT DETAILS ARE IN DIM_PRODUCTS -- 
LEFT JOIN gold.dim_products p 
ON f.product_number = p.product_number
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
     WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
    ELSE 'Avg'
END avg_change
FROM yearly_product_sales 
ORDER BY product_name

/* comparing the current sales with previous year's sales*/

WITH yearly_product_sales AS 
(
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON f.product_number = p.product_number
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
     WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
    ELSE 'Avg'
END avg_change,
-- helps us access previous year
-- YEAR OVER YEAR ANALYSIS FOR THE PRODUCTS SEASONALITY 
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
          ELSE 'No change'
END py_change
FROM yearly_product_sales 
ORDER BY product_name

