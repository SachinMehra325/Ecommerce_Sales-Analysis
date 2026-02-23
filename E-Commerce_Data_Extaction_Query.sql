-- Create Columns For Data
CREATE TABLE ecommerce_sales (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    quantity INTEGER CHECK (quantity > 0),
    sales DECIMAL(12,2) CHECK (sales >= 0),
    profit DECIMAL(12,2)
);

-- Get All Data and Inforamtion
SELECT * FROM ecommerce_sales

-- Load CSV File With Columns
COPY ecommerce_sales (order_date, product_name,category,region,quantity,sales,profit)
FROM 'D:\All\SQL_Projects\E-Commerce Sales Analysis\ecommerce_sales_data.csv'
DELIMITER ','
CSV HEADER;

-- First,Data Cleaning Process

-- 1. \d ecommerce_sales - Check to all Data Types

-- 2. Check All Total Rows
    SELECT COUNT(*) FROM ecommerce_sales;

-- 3.Check for NULL Values
   SELECT 
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_order_date,
    COUNT(*) FILTER (WHERE product_name IS NULL) AS null_product,
    COUNT(*) FILTER (WHERE category IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE region IS NULL) AS null_region,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity,
    COUNT(*) FILTER (WHERE sales IS NULL) AS null_sales,
    COUNT(*) FILTER (WHERE profit IS NULL) AS null_profit
FROM ecommerce_sales;

-- When we Null Values Are Present
   DELETE FROM ecommerce_sales
   WHERE order_date IS NULL
   OR  product_name IS NULL 
   OR quantity IS NULL;

-- 4.Check for Duplicates
SELECT 
    order_date,
    product_name,
    category,
    region,
    quantity,
    sales,
    profit,
    COUNT(*)
FROM ecommerce_sales
GROUP BY 
    order_date,
    product_name,
    category,
    region,
    quantity,
    sales,
    profit
HAVING COUNT(*) > 1;

-- Remove duplicates:
DELETE FROM ecommerce_sales a 
USING ecommerce_sales b
WHERE a.order_id > b.order_id
AND a.order_date = b.order_date
AND a.product_name = b.product_name
AND a.category = b.category
AND a.region = b.region
AND a.quantity = b.quantity
AND a.sales = b.sales
AND a.profit = b.profit;

-- 5.Check for Negative or Invalid Values

-- Check Negative Qty
   SELECT *
   FROM ecommerce_sales
   WHERE quantity <= 0 

-- Negative Sales
   SELECT * 
   FROM ecommerce_sales
   WHERE sales < 0;

-- Extreme Profit Loss
   SELECT * 
   FROM ecommerce_sales
   WHERE profit < 0;

-- If unrealistic, remove:
   DELETE FROM ecommerce_sales
   WHERE quantity <= 0 OR sales < 0;

-- 5. Standardize Text Data
   UPDATE ecommerce_sales
   SET 
   region = TRIM(region),
   product_name = TRIM(product_name), 
   category = TRIM(category)

   UPDATE ecommerce_sales
   SET region = INITCAP(region);

-- 6.Check Date Range
  SELECT MIN(order_date), MAX(order_date)
  FROM ecommerce_sales;

-- 7.Check Profit Margin Outliers
 SELECT *,
       ROUND((profit / sales),2) * 100 AS profit_margin
FROM ecommerce_sales
WHERE sales > 0
ORDER BY profit_margin DESC;

ALTER TABLE ecommerce_sales
ADD COLUMN profit_margin DECIMAL(5,2)

UPDATE ecommerce_sales
SET profit_margin = ROUND((profit / sales) * 100, 2)
WHERE sales > 0;

-- 8. Extract Month and Year From Data Column
SELECT 
    EXTRACT(MONTH FROM order_date) AS month
FROM ecommerce_sales;

SELECT 
    EXTRACT(YEAR FROM order_date) AS Year
FROM ecommerce_sales;

ALTER TABLE ecommerce_sales
ADD COLUMN order_month INT;

ALTER TABLE ecommerce_sales
ADD COLUMN order_year INT;


UPDATE ecommerce_sales
SET order_month = EXTRACT(MONTH FROM order_date);

UPDATE ecommerce_sales
SET order_year = EXTRACT(YEAR FROM order_date)

-- Solve to Business Question With Problem

-- 1. What is the Total Sales and Total Profit?
SELECT 
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM ecommerce_sales;

-- 2. What is the Overall Profit Margin?
SELECT ROUND((SUM(profit) /  SUM(sales)) * 100,2) AS profit_margin_percentage
FROM ecommerce_sales;

-- 3.Monthly Sales Trend
SELECT
   order_month,
   SUM(sales) AS monthly_sales
FROM ecommerce_sales
GROUP BY order_month
ORDER BY monthly_sales DESC;

-- 4.Top 5 Products by Sales
SELECT
   product_name,
   SUM(sales) AS total_sales
FROM ecommerce_sales
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;

-- 5.Top 5 Products by Profit
SELECT
   product_name,
   SUM(profit) AS total_profit
FROM ecommerce_sales
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 5;

-- 6.Which Category Makes Highest Sales?
SELECT
   category,
   SUM(sales) AS total_sales
FROM ecommerce_sales
GROUP BY category
ORDER BY total_sales DESC;

-- 7.Which Category Makes Highest Profit?
SELECT
   category,
   SUM(profit) AS total_profit
FROM ecommerce_sales
GROUP BY category
ORDER BY total_profit DESC;

-- 8. Which Region Generates Highest Sales?
SELECT
   region,
   SUM(sales) AS total_sales
FROM ecommerce_sales
GROUP BY region
ORDER BY total_sales DESC;

-- 9. Which Region Makes Highest Profit?
SELECT
   region,
   SUM(profit) AS total_profit
FROM ecommerce_sales
GROUP BY region
ORDER BY total_profit DESC;

-- 10. Which Products Are Loss Making?
SELECT
   product_name,
   SUM(profit) AS total_profit
FROM ecommerce_sales
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- 11.What is the Overall Profit Margin By Order_Month
SELECT
order_month,ROUND((SUM(profit) /  SUM(sales)) * 100,2) AS profit_margin_percentage
FROM ecommerce_sales
GROUP BY order_month

-- 12.Rank Products Within Each Category
SELECT
    category,
	product_name,
	SUM(sales) AS total_sales,
	RANK() OVER(
      PARTITION by category
	  ORDER BY SUM(sales) DESC
	) AS rank_in_category
FROM ecommerce_sales
GROUP BY category, product_name
ORDER BY category,rank_in_category;


-- 13.Contribution % of Each Category
SELECT
    category,
	SUM(sales) AS total_sales,
	ROUND(
        SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (),
		2
	)  AS contribution_percentage
FROM ecommerce_sales
GROUP BY category
ORDER BY contribution_percentage DESC;












   


