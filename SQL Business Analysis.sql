How much revenue, cost, and profit did the business generate?
SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Cost), 2) AS total_cost,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM sales;

Which year performed best?
SELECT
    Year,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Year
ORDER BY Year;

How fast is the business growing?
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
            total_revenue -
            LAG(total_revenue) OVER (ORDER BY Year)
        )
        /
        NULLIF(
            LAG(total_revenue) OVER (ORDER BY Year),
            0
        ) * 100,
        2
    ) AS yoy_growth_percentage
FROM yearly_sales
ORDER BY Year;

Which product categories generate the most revenue and profit?

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
ORDER BY total_revenue DESC;

Which products are the biggest revenue drivers?

SELECT
    Product,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Product
ORDER BY total_revenue DESC
LIMIT 10;

Which products generate the most profit?

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
ORDER BY total_profit DESC
LIMIT 10;

Which countries generate the most revenue and profit?

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
ORDER BY total_revenue DESC;

Which regions should receive more business investment?

SELECT
    State,
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY State, Country
ORDER BY total_revenue DESC
LIMIT 10;

Which customer segment creates the most value?

SELECT
    Age_Group,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Order_Quantity) AS total_quantity_sold
FROM sales
GROUP BY Age_Group
ORDER BY total_revenue DESC;


How does performance differ between customer groups?

SELECT
    Customer_Gender,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Order_Quantity) AS total_quantity_sold
FROM sales
GROUP BY Customer_Gender
ORDER BY total_revenue DESC;

This query uses RANK() to find the best-performing category within every country.

WITH category_performance AS (
    SELECT
        Country,
        Product_Category,
        SUM(Revenue) AS total_revenue,
        RANK() OVER (
            PARTITION BY Country
            ORDER BY SUM(Revenue) DESC
        ) AS category_rank
    FROM sales
    GROUP BY Country, Product_Category
)
SELECT
    Country,
    Product_Category,
    ROUND(total_revenue, 2) AS total_revenue
FROM category_performance
WHERE category_rank = 1
ORDER BY total_revenue DESC;

Are any products selling well but contributing relatively little profit?

WITH product_performance AS (
    SELECT
        Product,
        SUM(Revenue) AS total_revenue,
        SUM(Profit) AS total_profit,
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100 AS profit_margin
    FROM sales
    GROUP BY Product
)
SELECT
    Product,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin, 2) AS profit_margin_percentage
FROM product_performance
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM product_performance
)
ORDER BY profit_margin ASC;