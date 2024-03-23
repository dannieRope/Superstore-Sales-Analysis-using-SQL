# 1.0 INTRODUCTION 

A popular sample dataset from Tableau, the Superstore dataset includes fictitious sales data from a global superstore. 

It contains information about customers, products, orders, and geographic regions. It is an excellent resource for learning about retail sales operations and honing data analysis skills. 

As a data analyst, I have been tasked with writing SQL queries to analyze the dataset to uncover trends and patterns hidden within the dataset and also provide useful insights and 

recommendations to help in better decision-making in order to optimize sales performance. The insights gained from this analysis can then be used to identify areas for improvement and suggest strategies to increase sales. 

My aim is to analyze the superstore dataset by utilizing database management strategies, data visualization tools, and SQL queries in order to derive useful insights and useful information.

## 1.1 OBJECTIVES 
- Explore customer purchase patterns, segmentations, and preferences through SQL queries, aiming to personalize offerings and improve customer satisfaction.

- Assess the performance of different regions or markets within the Superstore, identifying areas of strength and opportunities for expansion or optimization.

- Analyze sales data to identify trends in product performance, seasonal variations, and regional preferences to make informed inventory and marketing decisions.

- Generate actionable insights from the analysis, empowering decision-makers to make informed and strategic choices that drive the Superstore’s growth and customer satisfaction.


## 1.2 THE DATASET 

### 1.2.1 Data Source and Structure

The superstore dataset is obtained from the Tableau [website](https://community.tableau.com/s/question/0D54T00000CWeX8SAL/detail); you can also find it on Kaggle via this [link](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final). The dataset consists of 9994 rows, excluding the header. It contains data recorded between the 3rd of January 2014 (the first order date) and the 30th of December 2017 (the last order date).
There are 21 columns. Below are the column names and their descriptions in the dataset. 

1. Row ID: unique ID for each row.
2. Order ID: a unique order ID for each customer.
3. Order Date: Order Date of the Product.
4. Ship Date: Shipping Date of the Product.
5. Ship Mode: The shipping mode specified by the customer.
6. Customer ID: a unique ID to identify each customer.
7. Customer Name: Name of the Customer.
8. Segment: The segment where the customer belongs.
9. Country: The country of residence of the customer.
10. City: the city of residence of the customer.
11. State: State of residence of the customer.
12. Postal Code: The postal code of every customer.
13. Region: the region where the customer belongs.
14. Product ID: a unique ID of the product.
15. Category: category of the product ordered.
16. Sub-Category: Subcategory of the product ordered.
17. Product Name: Name of the Product
18. Sales: sales of the product.
19. Quantity: quantity of the product.
20. Discount: Discount provided.
21. Profit: profit/loss incurred.

![Screenshot 2024-03-22 163938](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/20fe4182-2ccb-408c-8613-1efe048bf06e)


### 1.2.2 Tools

We will utilize Microsoft SQL Server Management Studio as our primary data tool for the processes of data cleaning, analysis, and visualization in PowerBI.

# 2.0 DATA CLEANING AND PREPARATION

## 2.1 Creating a database and importing data
First, we need to establish a fresh database named 'MarketData' to house both the data and pertinent details associated with this project. Following this setup, we will utilize Server Management Studio's Import and Export Wizard to import the CSV file ('superstoresales.csv'). 

To create a new database, proceed by clicking on the 'New Query' feature within the toolbar area of MS SQL Server Studio. This action will open a new query window. Within this window, execute the following commands:

```sql
DROP DATABASE IF EXISTS MarketData;
CREATE DATABASE MarketData;

```

These commands will first check if a database named MarketData already exists and drop it if it does. Then, it will create a fresh database named MarketData.

![Screenshot 2024-03-21 101912](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/eb5508b6-0437-4add-82b4-728627b4b19e)


In the Object Explorer, click on the refresh button and check the databases to find the newly created MarketData database.


![Screenshot 2024-03-21 102059](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/bc043a39-61de-4243-a807-707d35fb7d1b)


To import data into the MarketData Database, right-click on the database within SSMS, select  'Tasks' from the menu, then ‘Import Flat File’, and carefully follow the steps outlined by the wizard to configure the data import settings.


![Screenshot 2024-03-22 162617](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/3d1c104e-0135-4e59-8ef1-19a1db9db42d)


## 2.2 Checking values in column for accuracy and consistency

The next step is confirming the integrity of the imported data now that it has been imported into the database. It is necessary to verify if there are the same number of columns and rows as before the import. Also, inspect whether the columns have the right data types.


**Observe the data by retrieving first 10 records of the dataset**
```sql
        
 SELECT TOP 10 *
 FROM superstoresales;

```

![Screenshot 2024-03-21 110042](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/f6f7671b-159f-4efd-932c-c145f5489ef9)


**Check Column names and Datatypes**

```sql
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstoresales';
```

![columns and datatypes](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/d6baefa6-13ba-4979-8108-327a372b54ed)

This revealed that all columns are up to 21 and have the right data types as one before import. 

**Check the number or rows imported**

 ```sql
SELECT COUNT(*) AS Row_Count
FROM SuperStoreSales;
```

![Screenshot 2024-03-21 111347](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/c2ad87e4-c7b2-40af-a02b-8a4dcf3d8692)

Returns 9994 rows, which is the same as before import. 

**Checking for missing values**

```sql
SELECT * 
FROM superstoresales
WHERE Order_ID = NULL OR Order_ID = '  ' OR  LEN(Order_ID) = 0 OR
Order_Date =NULL OR Order_Date = '  ' OR LEN(Order_Date) = 0;
```

![Screenshot 2024-03-21 112604](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/11db3b53-d9f3-498b-b1d2-fe93269dffa2)

It returned empty rows, which indicates that there are no missing values. 

**Checking for duplicate values**

```sql
WITH duplicates_cte AS (
 SELECT *,
 ROW_NUMBER()OVER(PARTITION BY row_id, order_id, order_date, ship_date,ship_mode, customer_id, customer_name, segment, country, city, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit ORDER BY (SELECT NULL)) AS row_count
 FROM SuperStoreSales
)
SELECT * FROM duplicates_cte
WHERE Row_count > 1;
```
![Screenshot 2024-03-21 130328](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/4649f1e8-1e5d-44a3-a700-510fed0ddc34)

It returned empty rows, which indicates that there are duplicate values. 

# 3.0 DATABASE DESIGN
After validating the integrity of the imported flat file dataset comprising 21 columns, I proceeded to normalize the dataset into four distinct tables: dim_product, dim_geography, and dim_customer. 


Normalization is a database design technique used to organize data into multiple related tables to minimize redundancy and dependency. By dividing large tables into smaller, related tables, normalization aims to achieve data integrity and reduce the likelihood of anomalies during data manipulation.

Here's a brief explanation of each:

```dim_customer:```  contains information about the customers  

```dim_product:``` contains details about products, including their names, categories, descriptions, etc. 

```dim_geography:``` represents geographic information, such as country, city, region, postal code, etc. 

```factsales:``` contains sales transaction data. It typically contains references to the dim_customer, dim_product, and dim_geography tables, along with additional details such as sales amounts, quantities, dates, etc. 

Overall, normalization helps improve data integrity, reduce storage requirements, and enhance query efficiency by organizing data into logically related tables and eliminating redundant information. 

It also facilitates easier data management and ensures consistency across the database. I also created dim_calendar table which contains date, months, years, etc 

Find the SQL code for the normalization [here](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/commit/653559e7046e3d32000c66e27ed4412be5202298). Also below is an image of the database design. 

![Screenshot 2024-03-21 142903](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/9c5dd088-f2a2-4f6b-94d1-50e4555ef1f3)


# 4.0 EXPLORATORY DATA ANALYSIS (EDA)

## 4.1 Sales Analysis

**1. Total Sales Amount: Calculate the total sales amount for all transactions in the dataset.**
```sql
SELECT
      ROUND(SUM(Sales),2) AS total_sales
FROM FactSales;
```

![Screenshot 2024-03-23 053851](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/90b0256b-429c-4b37-b6b8-d4e4d18b6500)

**2. What is the total profit for all orders in the dataset?** 

```sql
SELECT 
      ROUND(SUM(profit),2) AS total_profit
FROM FactSales;
```
![Screenshot 2024-03-23 054249](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/f3f46171-6efe-4d48-be1e-34cc4652a460)

**3. How many orders are in the dataset?**

```sql
SELECT 
      COUNT(orderid) AS total_orders
FROM FactSales;
```

![Screenshot 2024-03-23 054527](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/bf2926ff-2de1-4154-91f4-f26ced6177d8)

**4. What is the average discount applied to orders?**

```sql
SELECT 
      ROUND(AVG(discount),2) AS avg_discount
FROM FactSales;
```

![image](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/65be0f87-086f-47f4-97d9-4523340628ad)

**5. How many orders were placed in each year?**

```sql
SELECT 
      YEAR(Orderdate) AS year,
	  COUNT(Orderid) AS total_orders
FROM FactSales
GROUP BY YEAR(Orderdate)
ORDER BY year;
```

![image](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/aa9a39f0-ec3f-4c2a-9e88-57a11df90a5f)


**6. Category Sales Growth: Calculate the year-over-year growth in sales for each product category.**

```sql
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
```

![image](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/27a8392a-e730-4ba8-be68-6118807952ba)


**7. Yearly Growth Rate: Calculate the yearly growth rate in sales from one year to the next, using window functions**

```sql
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
```

![image](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/f8c009a1-afd9-47a5-93bd-eca54d07e47c)


## 4.2 Customer Analysis

**1. Customer with the Highest Number of Orders: Find the customer who placed the highest number of orders.**

```sql
SELECT TOP 1 
    Customer_Name,
    COUNT(Orderid) AS total_orders
FROM dim_customer C
JOIN FactSales F ON C.Customer_ID = F.CustomerID
GROUP BY Customer_Name
ORDER BY total_orders DESC;
```

![Screenshot 2024-03-22 144900](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/e3bd9d41-ae39-4708-9d9e-cf745fa88897)

*-William Brown  is the customer with the highest number of orders placed.*

**2. Customer with the Highest Lifetime Value: Calculate the customer with the highest lifetime value, which is the sum of all purchases made by that customer.**

```sql
SELECT TOP 1 Customer_Name,
       ROUND(SUM(F.sales),2) AS CLT_Value
FROM dim_customer C
JOIN FactSales F
ON C.Customer_ID = F.CustomerID
GROUP BY Customer_Name
ORDER BY CLT_Value DESC;
```

![Screenshot 2024-03-22 145346](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/2dd22014-e46e-40bd-9cd6-cae5909b97ec)

*Sean Miller is the customer with the highest life time value*

**3. Identify customers who have made at least five purchases and calculate their average order value.**

```sql
SELECT 
    C.Customer_Name,
    COUNT(F.OrderId) AS purchases,
    ROUND(AVG(F.Sales), 2) AS avg_order_value
FROM dim_customer C
JOIN FactSales F ON C.Customer_ID = F.CustomerID
GROUP BY C.Customer_Name
HAVING COUNT(F.OrderId) >= 5
ORDER BY purchases, avg_order_value DESC;
```
![Screenshot 2024-03-22 145714](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/c32fe38c-f886-4543-a06a-e33b4f339a51)

**4. Customer Retention Rate: Determine the percentage of customers who made repeat purchases (more than one order) in 2017.**

```sql

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
```

![Screenshot 2024-03-22 145919](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/950c1054-e3ee-4b0a-8570-169ecc94e911)


*There was 100% customer retention rate in 2017*

**5. Customer Segmentation: Segment customers into different groups (e.g., high-value, medium-value, low-value) based on their total purchases, and analyze the average order value and frequency of each group.**

```sql
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
```
![Screenshot 2024-03-22 150257](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/0b0c03f2-421f-4995-bfcf-d8b3b7a6b9c4)

## 4.3 Product Analysis 

**1. Top 5 Most Sold Products: Retrieve the top 5 products by quantity sold.**

```sql
SELECT TOP 5 Product_Name,
       SUM(quantity) AS	qtysold
FROM dim_product p
JOIN FactSales f ON p.ProductKey = f.ProductKey
GROUP BY Product_Name
ORDER BY qtysold DESC;
```
![Screenshot 2024-03-22 170825](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/567652e8-6f58-4147-a12f-22c06e83d81a)

*Staples,Staple envelope,Easy-staple paper, Staples in misc. colors, KI Adjustable-Height Table are the top 5 products sold*

**2. Product with the Highest Profit: Find the product with the highest total profit.**

```sql
SELECT TOP 1 Product_Name,
       ROUND(SUM(Profit),2) AS profit
FROM dim_product p
JOIN FactSales f ON p.ProductKey = f.ProductKey
GROUP BY Product_Name
ORDER BY profit DESC;
```
![Screenshot 2024-03-22 171552](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/30d50f5f-ae70-44f5-82f2-1c422296c311)

*Canon imageCLASS 2200 Advanced Copier generated the highest profit*

**3. Profitable Products Across Regions: Find the top 3 most profitable products in each region.**
```sql
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

```
![Screenshot 2024-03-22 172031](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/b071632b-a192-4092-ab89-d2cc2db02252)


**4. Seasonal Sales Analysis: Identify the top-selling product category in each quarter of the year.**

```sql
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
       Year,
       product_name,
	   qty
FROM topselling_cte
WHERE quarter_rank = 1;
```

![Screenshot 2024-03-23 051352](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/66529430-b7c5-4e32-81a3-b0c0962d4bfd)



**5. Product Category Ranking: Rank product categories by total sales in descending order using window functions.**

```sql
SELECT category,
       ROUND(SUM(Sales),2) AS rank_cat,
	   RANK()OVER( ORDER BY SUM(Sales) DESC) AS rank_cat
FROM FactSales F
JOIN dim_product P ON F.ProductKey = P.ProductKey
GROUP BY Category;
```
![Screenshot 2024-03-23 051915](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/1a213ff1-1a41-4a11-b9e5-59cf37ee9dbb)

*The technology category ranks first, followed by furniture and office supplies, respectively.*

**6. What is the average discount for each product category?**
```sql
SELECT
       category,
       ROUND(AVG(discount),2) AS avg_discount
FROM FactSales F
JOIN dim_product P ON F.ProductKey = P.ProductKey
GROUP BY Category
ORDER BY avg_discount DESC;
```

![Screenshot 2024-03-23 052509](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/2c3908f1-dbbd-4830-9d2d-9349fc43d1dd)


**7. Find the top 5 customers who have made the highest total sales in each state, along with the product category they mostly purchased. 
Use a Common Table Expression (CTE) to calculate the total sales for each customer in each state, and then retrieve the top 5 customers for each state. 
Additionally, provide the product category that these top customers predominantly bought in each state.**

```sql
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
```

![Screenshot 2024-03-23 053036](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/43a29d87-1442-45ba-99ad-2a3b142d67a8)

## 4.4 Location Analysis 

```sql
SELECT 
      Region,
	  ROUND(SUM(Sales),2) AS total_revenue,
	  ROUND(SUM(profit),2) AS total_profit
FROM FactSales f
JOIN dim_geography g ON f.GeographyKey = g.GeographyKey
GROUP BY Region
ORDER BY total_revenue DESC,total_profit
```

![image](https://github.com/dannieRope/Superstore-Sales-Analysis-using-SQL/assets/132214828/78302219-babe-4190-b341-d6eb0ed6c8c5)


# 5.0 INSIGHTS AND RECOMMENDATION

- The total number orders placed from 2014 - 2017 is 9,994 which generated about $2,297,201 in revenue along with $286,397.02 profit realized.
  
- The order count exhibited a consistent increase year by year, escalating from 1,993 orders in 2014 to a peak of 3,312 orders in 2017. Among the observed years, 2017 marked the highest number of orders, while 2014 recorded the lowest volume. 

- The products in the “Technology” category generated the highest sales.
  
- Among categories, “Office Supplies” stands out with 6,026 orders, concurrently having the highest count of returns at 296.

- Staples is the mosted ordered product however, Canon imageCLASS 2200 Advanced Copier is the most profitable product.

- The most performing regions are the West then the East, Central and South regions in that order. It also good to note that, Canon imageCLASS 2200 Advanced Copier is the most profitable product in all the regionsexcept for the south with Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind as the most profitable product.

- William Brown is the customer with the most orders placed however, Sean Miller is the customer with most spending 















