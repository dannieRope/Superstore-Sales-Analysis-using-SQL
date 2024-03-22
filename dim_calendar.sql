USE MarketData;

/*CREATING DIM_CALENDAR TABLE*/

--Retrieve all data from Factsales table
SELECT *
FROM FactSales;

--Find the minimum and maximum date value in the OrderDate column
SELECT MIN(OrderDate) AS FirstDate,
       MAX(orderDate) AS LastDate
FROM Factsales;

--Create dim_calendar Table
DROP TABLE IF EXISTS dim_calendar;
CREATE TABLE dim_calendar(
    DateKey DATE NOT NULL PRIMARY KEY,
    Year AS (YEAR(DateKey)),
    Quarter AS CONCAT('Q',DATEPART(QUARTER,DateKey)),
    Month  AS MONTH(DateKey),
    MonthName AS DATENAME(MONTH,DateKey),
	Day AS DAY(DateKey)
);


--Declare MIN and MAX OrderDate as Variables 
DECLARE @StartDate DATE = (SELECT MIN(OrderDate)
                           FROM FactSales);
DECLARE @EndDate DATE = (SELECT MAX(OrderDate)
                           FROM FactSales);

--Create a recursive cte Dim_date to generate dates
WITH dim_date AS (
    SELECT @StartDate AS date
  UNION ALL 
    SELECT DATEADD(DAY,1,date)
    FROM dim_date
    WHERE date <= @EndDate)

INSERT INTO dim_calendar
SELECT date 
FROM dim_date
OPTION (MAXRECURSION 0);

SELECT * 
FROM dim_calendar;

--add foreign key constraint to Order_date in the Sales table 
ALTER TABLE factsales 
ADD CONSTRAINT FK_Calendar FOREIGN KEY(OrderDate) REFERENCES dim_calendar(DateKey);

--Check all the constraint in the factsales

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Factsales';
