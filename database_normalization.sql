/*NORMALIZING THE FLAT FILE IN TO FOUR TABLES*/

--DIM_CUSTOMER TABLE

--Creating the dim_customer table
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    Customer_ID NVARCHAR(50) PRIMARY KEY NOT NULL,
    Customer_Name NVARCHAR(50),
    Segment NVARCHAR(50)
);

--Migrate data from Superstoresales table into the dim_customer table
INSERT INTO dim_customer
SELECT DISTINCT Customer_ID, Customer_Name,Segment
FROM SuperstoreSales;

--Retreive all rows from the dim_customer table
SELECT *
FROM dim_customer;

--Checking the integrity of the dim_customer table
SELECT COUNT(DISTINCT(Customer_ID))
FROM SuperStoreSales; --Compare with count of customer_id in the dim_customer

SELECT COUNT(customer_id)
FROM dim_customer;

--DIM_GEOGRAPHY TABLE
--Creating dim_geography table
DROP TABLE IF EXISTS dim_geography;
CREATE TABLE dim_geography(
    GeographyKey INT NOT NULL IDENTITY(100,1) PRIMARY KEY,
    Postal_Code INT,
    Region VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50))

--Migrating Data from superstoresales table to dim_geography table
INSERT INTO dim_geography
SELECT  DISTINCT 
        Postal_Code,
        Region,
        State,
        Country,
        City
FROM SuperstoreSales;

--Retreive all rows from the dim_geography table
SELECT *
FROM dim_geography;

--Checking the integrity of the dim_geography table
SELECT COUNT(DISTINCT(GeographyKey))
FROM dim_geography; --Compare with distinct count of postal_code in the superstoresales table

SELECT COUNT(DISTINCT Postal_Code)
FROM SuperStoreSales;

--DIM_PRODUCT TABLE
--Creating dim_product table
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product(
    ProductKey INT NOT NULL IDENTITY(10,1) PRIMARY KEY,
    Product_ID NVARCHAR(50),
    Product_Name NVARCHAR(225),
    Category NVARCHAR(128),
    Sub_Category NVARCHAR(128)
);

--Migrating data from superstoresales table to dim_product table
INSERT INTO dim_product
SELECT  DISTINCT
        Product_ID,
        Product_Name,
        Category,
        Sub_Category
FROM SuperstoreSales;

--Retreive all rows from the dim_product table
SELECT *
FROM dim_product;

--Integrety checks
SELECT COUNT(*)
FROM dim_product;

SELECT COUNT(product_id),
       COUNT(DISTINCT(Product_ID)),
       COUNT(DISTINCT(CONCAT(Product_ID,Product_Name)))--represented by the productKey in the dim_product table
FROM SuperStoreSales;


--THE FACTSALES TABLE
--Creating the Factsales table
DROP TABLE IF EXISTS FactSales;
CREATE TABLE FactSales(
    OrderId NVARCHAR(50) NOT NULL,
    OrderDate DATE NOT NULL,
    ShipDate DATE,
    ShipMode VARCHAR(25),
    CustomerID NVARCHAR(50) NOT NULL,
    ProductKey INT NOT NULL,
    GeographyKey INT NOT NULL,
    Sales FLOAT,
    Quantity INT,
    Discount FLOAT,
    Profit FLOAT,
    CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) REFERENCES dim_customer(Customer_ID),
    CONSTRAINT FK_Product FOREIGN KEY (ProductKey) REFERENCES dim_product(ProductKey),
    CONSTRAINT FK_Geography FOREIGN KEY (GeographyKey) REFERENCES dim_geography(GeographyKey)
);

--Migrating data from superstoresales table to the Factsales table
INSERT INTO FactSales
SELECT Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,P.ProductKey,G.GeographyKey,sales,Quantity,Discount,Profit
FROM SuperStoreSales S
LEFT JOIN dim_product P
ON S.Product_Name = P.Product_Name AND P.Product_ID =S.Product_ID
LEFT JOIN dim_geography G 
ON S.Postal_Code = G.[Postal_Code] AND S.City= G.City

--Retreive all rows from the Factsales table
SELECT *
FROM FactSales;

--Integrity checks
SELECT COUNT(*)
FROM FactSales;

SELECT COUNT(*)
FROM SuperStoreSales; --Both should give the same amount of rows

ALTER TABLE dim_product
DROP Product_ID;

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'dim_product';
