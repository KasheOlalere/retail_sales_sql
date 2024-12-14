DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

select count(*) from retail_sales;

--Check the table for null values:
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL OR
		sale_date IS NULL OR
		sale_time IS NULL OR
		customer_id IS NULL OR
		gender IS NULL OR
		category IS NULL OR
		quantity IS NULL OR
		price_per_unit IS NULL OR
		cogs IS NULL OR
		total_sale IS NULL ;

-- DELETE rows with null values.
DELETE
FROM retail_sales
WHERE transactions_id IS NULL OR
		sale_date IS NULL OR
		sale_time IS NULL OR
		customer_id IS NULL OR
		gender IS NULL OR
		category IS NULL OR
		quantity IS NULL OR
		price_per_unit IS NULL OR
		cogs IS NULL OR
		total_sale IS NULL ;

-- Number of sales made
select count(*) as total_sales from retail_sales;

-- Number of customers 
select count(distinct(customer_id)) as no_customers from retail_sales;

-- Number of categories
select count(distinct(category)) as no_category from retail_sales;

-- Data.head()
SELECT * 
FROM retail_sales
ORDER BY 4
-- LIMIT 5;

SELECT count(DISTINCT customer_id)
from retail_sales
-- Key questions:
-- 1 Query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2 Query to retrieve the amount of sales made each day
SELECT sale_date, count(*) as sales_made
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;

-- 3 Query to calculate the total sales (total_sale) for each category.
SELECT category, count(*) as sales_by_category
FROM retail_sales
GROUP BY category;

-- 4 Query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- 5 Query to find the total number of transactions made by each gender and the total sales in each category
SELECT gender,category,count(transactions_id) as no_sales,SUM(total_sale) AS amount_spent
FROM retail_sales
GROUP BY gender,category
ORDER BY 2,1;

-- 6 Query to calculate the average sale for each month. Find out best selling month in each year
SELECT 	DISTINCT(EXTRACT(MONTH FROM sale_date)) AS MONTH,
		EXTRACT(YEAR FROM sale_date) AS YEAR,
		AVG(total_sale) AS month_average		
FROM retail_sales
GROUP BY 1,2
ORDER BY 3 DESC;

SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
)
WHERE rank = 1;

-- 7 Query to find the top 5 customers based on the highest total sales
SELECT customer_id, sum(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER bY 2 DESC
LIMIT 5;

-- 8 Query to find the number of unique customers who purchased items from each category.
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category

-- 9 Query to find the amount of customers that made a purchase in each of the 3 categories.
SELECT distinct customer_id, COUNT(DISTINCT category) as cat_shopped
FROM retail_sales
WHERE category IN ('Electronics', 'Beauty', 'Clothing')
GROUP BY 1
--HAVING COUNT(DISTINCT category) = 3

-- 10 Query to find the top shopper for each of the categories
SELECT customer_id, category, sum_sales
FROM (SELECT customer_id, category, 
		SUM(total_sale) as sum_sales, 
		RANK () OVER(PARTITION BY category ORDER BY sum(total_sale)DESC) as top_customers
	  FROM retail_sales
	  GROUP BY 1,2
	  ORDER BY 4 )
WHERE top_customers = 1

-- 11 Query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'Evening'
	END AS Shift,
	SUM (total_sale) AS sum_sales,
	COUNT (*) AS No_orders
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
