/* Part-to-whole analysis: to analyse how an individual category has a greater impact on the business 
([Measure]/ total [measure]) x 100 by [Dimension]
(Sales/total sales) * 100 by category
(Quantity/ total quantity) * 100 by country */

-- 1. Which category has the most impact in comparison to overall sales? 
SELECT
category,
SUM(sales_amount) total_sales
FROM 
gold.fact_sales as f 
LEFT JOIN gold.dim_products p
ON p.product_number = f.product_number 
GROUP BY category

--using window function to check 
WITH category_sales AS 
(
SELECT
category,
SUM(sales_amount) total_sales
FROM 
gold.fact_sales as f 
LEFT JOIN gold.dim_products p
ON p.product_number = f.product_number 
GROUP BY category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND ((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100,2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
-- PERCENTAGE DATA MAKES IT EASIER TO SEE WHICH CATEGORY IS UNDERPERFORMING. IN THIS CASE, BIKES IS THE BEST PERFORMING CATEGORY WITH THE MOST REVENUE
-- Accessories and clothing have the least, almost negligent, in comparison to bikes  