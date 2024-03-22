USE MarketData;

--CUSTOMER ANALYSIS
--1. Customer with the Highest Number of Orders: Find the customer who placed the highest number of orders.
SELECT TOP 1 
    Customer_Name,
    ROUND(SUM(F.sales), 2) AS CLT_Value
FROM dim_customer C
JOIN FactSales F ON C.Customer_ID = F.CustomerID
GROUP BY Customer_Name
ORDER BY CLT_Value DESC;

--2. Customer with the Highest Lifetime Value: Calculate the customer with the highest lifetime value, which is the sum of all purchases made by that customer.
SELECT TOP 1 Customer_Name,
       ROUND(SUM(F.sales),2) AS CLT_Value
FROM dim_customer C
JOIN FactSales F
ON C.Customer_ID = F.CustomerID
GROUP BY Customer_Name
ORDER BY CLT_Value DESC;

--3. Which customers have returned orders, and how many times?

--4. Identify customers who have made at least five purchases and calculate their average order value.
SELECT 
    C.Customer_Name,
    COUNT(F.OrderId) AS purchases,
    ROUND(AVG(F.Sales), 2) AS avg_order_value
FROM dim_customer C
JOIN FactSales F ON C.Customer_ID = F.CustomerID
GROUP BY C.Customer_Name
HAVING COUNT(F.OrderId) >= 5
ORDER BY purchases, avg_order_value DESC;


--5. Customer Retention Rate: Determine the percentage of customers who made repeat purchases (more than one order) in 2017.

WITH Customer2017_cte AS (
    SELECT DISTINCT CustomerID
    FROM FactSales
    WHERE YEAR(OrderDate) = 2017
    GROUP BY CustomerID
    HAVING COUNT(Orderid) > 1 --all customers who made repeated purchases in 2017
),
allCustomer_cte AS (
    SELECT  DISTINCT CustomerID
    FROM FactSales
    WHERE YEAR(OrderDate) = 2017 --Total customers who made purchases in 2017
)

SELECT 
    ROUND(COUNT(c.CustomerID) * 100.0 / COUNT(a.CustomerID),0) as retention_rate
FROM Customer2017_cte c
JOIN allCustomer_cte a 
ON c.CustomerID = a.CustomerID;

/*6.Customer Segmentation: Segment customers into different groups (e.g., high-value, medium-value, low-value) based on their total purchases,
and analyze the average order value and frequency of each group.*/
WITH CustomerSegment AS (
    SELECT CustomerID,
           SUM(Sales) AS total_purchases
    FROM FactSales
    GROUP BY CustomerID
),
    Segmentation AS (
    SELECT CustomerID,
           total_purchases,
           CASE 
               WHEN total_purchases < 1000 THEN 'Low-Value' 
               WHEN total_purchases BETWEEN 1000 AND 10000 THEN 'Medium-Value' 
               ELSE 'High-Value' 
           END AS customer_segment
    FROM CustomerSegment
)
SELECT 
    customer_segment,
    COUNT(CustomerID) AS customer_count,
    ROUND(SUM(total_purchases),2) AS total_purchases,
    ROUND(AVG(total_purchases),2) AS average_order_value
FROM  Segmentation
GROUP BY customer_segment;

--PRODUCT ANALYSIS
--1. Top 5 Most Sold Products: Retrieve the top 5 products by quantity sold.
SELECT TOP 5 Product_Name,
       SUM(quantity) AS	qtysold
FROM dim_product p
JOIN FactSales f ON p.ProductKey = f.ProductKey
GROUP BY Product_Name
ORDER BY qtysold DESC;


--2. Product with the Highest Profit: Find the product with the highest total profit.
SELECT TOP 1 Product_Name,
       ROUND(SUM(Profit),2) AS profit
FROM dim_product p
JOIN FactSales f ON p.ProductKey = f.ProductKey
GROUP BY Product_Name
ORDER BY profit DESC;

--3. Profitable Products Across Regions: Find the top 3 most profitable products in each region.
WITH ProfitableProducts AS (
    SELECT 
        Region,
        Product_Name,
        ROUND(SUM(profit),2) AS total_profit,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY SUM(profit) DESC) AS product_rank
    FROM FactSales f
    JOIN  dim_product d ON f.ProductKey = d.ProductKey
    JOIN  dim_geography g ON f.GeographyKey = g.GeographyKey
    GROUP BY  Region, Product_Name
)
SELECT  Region,
        Product_Name,
        total_profit
FROM  ProfitableProducts
WHERE 
    product_rank <= 3;

--4. Seasonal Sales Analysis: Identify the top-selling product category in each quarter of the year.
WITH topselling_cte AS (
                 SELECT CONCAT('Q',DATEPART(QUARTER,Orderdate)) AS quarters,
				 YEAR(Orderdate) AS Year,
				 Product_name,
				 SUM(Quantity) As qty,
				 ROW_NUMBER() OVER(PARTITION BY CONCAT('Q',DATEPART(QUARTER,Orderdate)),YEAR(Orderdate) ORDER BY SUM(Quantity)DESC) AS quarter_rank
				 FROM FactSales F
				 JOIN dim_product D ON F.ProductKey = D.ProductKey
				 GROUP BY CONCAT('Q',DATEPART(QUARTER,Orderdate)),YEAR(Orderdate),Product_name
)
SELECT quarters,
       product_name,
	   qty
FROM topselling_cte
WHERE quarter_rank = 1;

--Product Category Ranking: Rank product categories by total sales in descending order using window functions.
SELECT category,
       ROUND(SUM(Sales),2) AS rank_cat,
	   RANK()OVER( ORDER BY SUM(Sales) DESC) AS rank_cat
FROM FactSales F
JOIN dim_product P ON F.ProductKey = P.ProductKey
GROUP BY Category;

--What is the average discount for each product category?
SELECT 
		category,
		ROUND(AVG(discount),2) AS avg_discount
FROM FactSales F
JOIN dim_product P ON F.ProductKey = P.ProductKey
GROUP BY Category
ORDER BY avg_discount DESC;

/*Find the top 5 customers who have made the highest total sales in each state, along with the product category they mostly purchased.
Use a Common Table Expression (CTE) to calculate the total sales for each customer in each state, and then retrieve the top 5 customers for each state.
Additionally, provide the product category that these top customers predominantly bought in each state.*/

WITH cte_customer AS (
                SELECT 
				      state,
					  Customer_Name,
					  category,
					  ROUND(SUM(Sales),2) AS total_sales,
					  ROW_NUMBER()OVER(PARTITION BY state ORDER BY SUM(Sales) DESC) AS sales_rank
				FROM Factsales F
				JOIN dim_customer c ON f.customerId = c.Customer_ID
				JOIN dim_product p ON f.productkey = p.productkey
				JOIN dim_geography g ON f.geographyKey = g.geographyKey
				GROUP BY state,Customer_Name,Category
)
SELECT State,
       Customer_Name,
	   Category,
	   total_sales
FROM cte_customer
WHERE sales_rank <= 5;

/*
LOCATION ANALYSIS
*/
--Profit by Region: Calculate the total profit  and total sales revenue for each region?
SELECT 
      Region,
	  ROUND(SUM(Sales),2) AS total_revenue,
	  ROUND(SUM(profit),2) AS total_profit
FROM FactSales f
JOIN dim_geography g ON f.GeographyKey = g.GeographyKey
GROUP BY Region
ORDER BY total_revenue DESC,total_profit

--SALES ANALYSIS

--Total Sales Amount: Calculate the total sales amount for all transactions in the dataset.
SELECT
      ROUND(SUM(Sales),2) AS total_sales
FROM FactSales;

--What is the total profit for all orders in the dataset?
SELECT 
      ROUND(SUM(profit),2) AS total_profit
FROM FactSales;

--How many orders are in the dataset?
SELECT 
      COUNT(orderid) AS total_orders
FROM FactSales;

--What is the average discount applied to orders?
SELECT 
      ROUND(AVG(discount),2) AS avg_discount
FROM FactSales;

--How many orders were placed in each year?
SELECT 
      YEAR(Orderdate) AS year,
	  COUNT(Orderid) AS total_orders
FROM FactSales
GROUP BY YEAR(Orderdate)
ORDER BY year;

--Category Sales Growth: Calculate the year-over-year growth in sales for each product category.
WITH year_sales AS (
      SELECT 
            YEAR(orderdate) AS sales_year,
			category,
            ROUND(SUM(Sales),2) AS total_sales,
	        LAG(ROUND(SUM(Sales),2))OVER(PARTITION BY category ORDER BY YEAR(orderdate)) AS previous_year_sales
      FROM FactSales f
	  JOIN dim_product p ON f.ProductKey = p.ProductKey
      GROUP BY  YEAR(orderdate),Category
)
SELECT 
      sales_year,
	  category,
	  total_sales,
	  ROUND((total_sales - previous_year_sales)/previous_year_sales,2) AS yoy_growth
FROM year_sales

---Yearly Growth Rate: Calculate the yearly growth rate in sales from one year to the next, using window functions.
SELECT 
       sales_year,
	   total_sales,
	   ROUND(((total_sales - previous_year_sales)/previous_year_sales)*100,2) AS yoy_growth
FROM (SELECT 
           YEAR(Orderdate) AS sales_year,
	       ROUND(SUM(sales),2) AS total_sales,
	       LAG(ROUND(SUM(sales),2))OVER(ORDER BY YEAR(Orderdate)) AS previous_year_sales
      FROM FactSales
	  GROUP BY YEAR(OrderDate)
	  ) AS yearly_sales
                      






















