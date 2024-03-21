# 1.0 INTRODUCTION 

A popular sample dataset from Tableau, the Superstore dataset includes fictitious sales data from a global superstore. It contains information about customers, products, orders, and geographic regions. It is an excellent resource for learning about retail sales operations and honing data analysis skills. 
As a data analyst, I have been tasked with writing SQL queries to analyze the dataset to uncover trends and patterns hidden within the dataset and also provide useful insights and recommendations to help in better decision-making in order to optimize sales performance. The insights gained from this analysis can then be used to identify areas for improvement and suggest strategies to increase sales. 
My aim is to analyze the superstore dataset by utilizing database management strategies, data visualization tools, and SQL queries in order to derive useful insights and useful information.

## 1.1 OBJECTIVES 
-Explore customer purchase patterns, segmentations, and preferences through SQL queries, aiming to personalize offerings and improve customer satisfaction.

-Assess the performance of different regions or markets within the Superstore, identifying areas of strength and opportunities for expansion or optimization.

-Analyze sales data to identify trends in product performance, seasonal variations, and regional preferences to make informed inventory and marketing decisions.

-Generate actionable insights from the analysis, empowering decision-makers to make informed and strategic choices that drive the Superstore’s growth and customer satisfaction.


## 1.2 THE DATASET 

### 1.2.1 Data Source and Structure

The superstore dataset is obtained from the Tableau website; you can also find it on Kaggle via this link. The dataset consists of 9994 rows, excluding the header. It contains data recorded between the 3rd of January 2014 (the first order date) and the 30th of December 2017 (the last order date).
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



In the Object Explorer, click on the refresh button and check the databases to find the newly created MarketData database.




To import data into the MarketData Database, right-click on the database within SSMS, select  'Tasks' from the menu, then ‘Import Flat File’, and carefully follow the steps outlined by the wizard to configure the data import settings.

## 2.2 Checking values in column for accuracy and consistency

The next step is confirming the integrity of the imported data now that it has been imported into the database. It is necessary to verify if there are the same number of columns and rows as before the import. Also, inspect whether the columns have the right data types.


Observe the data by retrieving first 10 records of the dataset
```sql
        
 SELECT TOP 10 *
 FROM superstoresales;

```

Check Column names and Datatypes

```sql
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstoresales';
```




