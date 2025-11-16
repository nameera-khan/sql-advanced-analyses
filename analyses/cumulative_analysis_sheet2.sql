-- aggregating using window functions for cumulative analysis of the business
-- calculate the total sales per month
-- calculate running total of sales over time 

SELECT 
DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) as order_date,
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0)

-- cumulative for running total
SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT 
    DATEADD(YEAR, DATEDIFF(YEAR, 0, order_date), 0) as order_date,
    SUM(sales_amount) as total_sales
    FROM gold.fact_sales
    WHERE order_date is not null
    GROUP BY DATEADD(YEAR, DATEDIFF(YEAR, 0, order_date), 0) 
) t -- window function
-- THE partition by function creates a cumulative window for each fiscal year. hence partitioning the sales of each year from the next.

--moving average price in sales 
SELECT 
order_date,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
    DATEADD(YEAR, DATEDIFF(YEAR, 0, order_date), 0) as order_date,
    SUM(sales_amount) as total_sales,
    AVG(sales_price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date is not null
    GROUP BY DATEADD(YEAR, DATEDIFF(YEAR, 0, order_date), 0) 
) v

