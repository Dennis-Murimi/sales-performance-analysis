CREATE DATABASE sales1_db;

USE sales1_db;

Q1. How many records are in the dataset?
SELECT COUNT(*) AS total_records
FROM sales;


Q4. How many countries, products, and customers are represented?
SELECT
    COUNT(DISTINCT Country) AS total_countries,
    COUNT(DISTINCT Product) AS total_products
FROM sales;

What are the total revenue, cost, and profit?

SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Cost), 2) AS total_cost,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM sales;

What is the total quantity sold?
SELECT
    SUM(Order_Quantity) AS total_quantity_sold
FROM sales;

What is the average revenue and profit per transaction?
SELECT
    ROUND(AVG(Revenue), 2) AS avg_revenue_per_transaction,
    ROUND(AVG(Profit), 2) AS avg_profit_per_transaction
FROM sales;

How does revenue and profit change by year?
SELECT
    Year,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Year
ORDER BY Year;

What is the year-over-year revenue growth?
WITH yearly_sales AS (
    SELECT
        Year,
        SUM(Revenue) AS total_revenue
    FROM sales
    GROUP BY Year
)
SELECT
    Year,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        (
            total_revenue - LAG(total_revenue) OVER (ORDER BY Year)
        ) /
        NULLIF(
            LAG(total_revenue) OVER (ORDER BY Year),
            0
        ) * 100,
        2
    ) AS yoy_growth_percentage
FROM yearly_sales
ORDER BY Year;

Which months generate the highest revenue?
SELECT
    Month,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Month
ORDER BY total_revenue DESC;

Which product categories generate the most revenue?
SELECT
    Product_Category,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Product_Category
ORDER BY total_revenue DESC;

Which category has the highest profit margin?
SELECT
    Product_Category,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY Product_Category
ORDER BY profit_margin_percentage DESC;

What are the top 10 products by revenue?
SELECT
    Product,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Product
ORDER BY total_revenue DESC
LIMIT 10;

What are the top 10 products by profit?
SELECT
    Product,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Product
ORDER BY total_profit DESC
LIMIT 10;

Which products sell the highest quantities?
SELECT
    Product,
    SUM(Order_Quantity) AS total_quantity_sold
FROM sales
GROUP BY Product
ORDER BY total_quantity_sold DESC
LIMIT 10;

Which countries generate the most revenue?
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Country
ORDER BY total_revenue DESC;

Which countries have the highest profit margins?
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY Country
ORDER BY profit_margin_percentage DESC;

What are the top 10 states by revenue?
SELECT
    State,
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY State, Country
ORDER BY total_revenue DESC
LIMIT 10;

Which age group generates the most revenue?
SELECT
    Age_Group,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Age_Group
ORDER BY total_revenue DESC;

Which category performs best in each country?
WITH category_sales AS (
    SELECT
        Country,
        Product_Category,
        SUM(Revenue) AS total_revenue,
        RANK() OVER (
            PARTITION BY Country
            ORDER BY SUM(Revenue) DESC
        ) AS sales_rank
    FROM sales
    GROUP BY Country, Product_Category
)
SELECT
    Country,
    Product_Category,
    ROUND(total_revenue, 2) AS total_revenue
FROM category_sales
WHERE sales_rank = 1
ORDER BY total_revenue DESC;

Which products have high revenue but low profit margins?
SELECT
    Product,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY Product
HAVING SUM(Revenue) > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT SUM(Revenue) AS product_revenue
        FROM sales
        GROUP BY Product
    ) AS product_summary
)
ORDER BY profit_margin_percentage ASC;