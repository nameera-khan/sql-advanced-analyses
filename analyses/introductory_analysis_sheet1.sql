-- Analysing sales performance 
SELECT 
order_date,
sales_amount
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
ORDER BY order_date

--Aggregate by sales amount and group by order date
SELECT 
YEAR(order_date),
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) -- Aggregating based on year makes it much easier to see the trend within the business on a yearly basis

-- count the customers 
SELECT 
YEAR(order_date) as order_year,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(sales_quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- Monthly performance for seasonality of business 
SELECT 
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(sales_quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- Using DATETRUNC to order the month and date (THIS DOES NOT WORK IN AZURE STUDIO SQL)
SELECT 
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(sales_quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

-- TRYING AN ALTERNATIVE TO DATETRUNC
SELECT 
    DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) as order_month,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(sales_quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0)
ORDER BY DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0)




