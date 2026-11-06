create database Adventure_Project;
use Adventure_Project;
show tables;
select * from factinternetsales;
select * from fact_internet_sales_new;
/* 0. Union of Fact Internet sales and Fact internet sales new*/
create table fact_sales as (
select * from factinternetsales
union all
select * from fact_internet_sales_new);
select count(*) from factinternetsales;
select count(*) from fact_internet_sales_new;
select * from fact_sales;
select count(*) from fact_sales;
drop table fact_sales;
/* ------End 1st qstn------*/
select * from dimproduct;
select * from dimproductsubcategory;
select * from dimproductcategory;
create table dim_product_subcategory as
(select 
		dp.*,
        dpsc.ProductSubcategoryAlternateKey,EnglishProductSubcategoryName,SpanishProductSubcategoryName,FrenchProductSubcategoryName,ProductCategoryKey
from dimproduct dp
left join 
	 dimproductsubcategory dpsc
ON dp.ProductSubcategoryKey=dpsc.ProductSubcategoryKey);  
select * from dim_product_Cat_Subcat;
create table dim_product_Cat_Subcat as
(select 
		dps.*,
        dpc.ProductCategoryAlternateKey,EnglishProductCategoryName,SpanishProductCategoryName,FrenchProductCategoryName
from dim_product_subcategory  dps
left join 
	 dimproductcategory dpc
ON dps.ProductCategoryKey=dpc.ProductCategoryKey);  
/*1.Lookup the productname from the Product sheet to Sales sheet.*/
create table saleswithproductname as
select 
		s.*,
        p.EnglishProductName as Product_name
from fact_sales s
left join dim_product_Cat_Subcat p
on s.ProductKey=p.ProductKey;
select * from saleswithproductname;
/*--------------End Q-2----------------*/
Select * from dimcustomer;
select * from fact_sales;
/* 2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.*/
create table Sales_unitprice_customerName as
select
	s.*,
    c.Full_Name as Customer_Name
from fact_sales s
left Join dimcustomer c
          ON s.CustomerKey=c.CustomerKey
left join dim_product_Cat_Subcat p
           ON s.ProductKey=p.ProductKey;
select * from Sales_unitprice_customerName;
/*------------End Q-2----------*/
/*3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
   A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth
   I. Financial Quarter 
  */
  Create Table OrderDateField as
  SELECT 
    OrderDateKey1,
    
    -- A. Year
    YEAR(OrderDateKey1) AS Year,
    
    -- B. Monthno (1 to 12)
    MONTH(OrderDateKey1) AS MonthNo,
    
    -- C. Monthfullname (January, February...)
    MONTHNAME(OrderDateKey1) AS MonthFullName,
    
    -- D. Quarter (Q1, Q2, Q3, Q4)
    CONCAT('Q', QUARTER(OrderDateKey1)) AS Quarter,
    
    -- E. YearMonth (YYYY-MMM e.g., 2023-Jan)
    DATE_FORMAT(OrderDateKey1, '%Y-%b') AS YearMonth,
    
    -- F. Weekdayno (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    DAYOFWEEK(OrderDateKey1) AS WeekdayNo,
    
    -- G. Weekdayname (Sunday, Monday...)
    DAYNAME(OrderDateKey1) AS WeekdayName,
    
    -- H. Financial Month (April = 1, March = 12)
    CASE 
        WHEN MONTH(OrderDateKey1) >= 4 THEN MONTH(OrderDateKey1) - 3 
        ELSE MONTH(OrderDateKey1) + 9 
    END AS FinancialMonth,
    
    -- I. Financial Quarter (Apr-Jun = Q1, Jan-Mar = Q4)
    CASE 
        WHEN QUARTER(OrderDateKey1) = 1 THEN 'Q4' 
        ELSE CONCAT('Q', QUARTER(OrderDateKey1) - 1) 
    END AS FinancialQuarter

FROM fact_sales;
ALTER TABLE fact_sales 
MODIFY COLUMN OrderDateKey1 DATE;
-- SHOW COLUMNS provides the exact same output
SHOW COLUMNS FROM fact_sales;
set sql_safe_updates=0;  -- Disable safe update mode
UPDATE fact_sales
SET OrderDateKey1 = NULL 
WHERE OrderDateKey1 = '' OR OrderDateKey1 = ' ';
UPDATE fact_sales
SET OrderDateKey1 = STR_TO_DATE(OrderDateKey1, '%d-%m-%Y')
WHERE OrderDateKey1 IS NOT NULL;
ALTER TABLE fact_sales
MODIFY COLUMN OrderDateKey1 date;
Select * from orderdatefield;
/*-----------End Q-3----------*/
/*4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)*/
select * from fact_sales;
select 
		UnitPrice,
        OrderQuantity,
        UnitPriceDiscountPct,
        (UnitPrice*OrderQuantity)*(1-UnitPriceDiscountPct) as Sales_Amount
from fact_sales;
/*-------End Q-4-----------*/
/*5.Calculate the Productioncost uning the columns(unit cost ,order quantity)*/
select
		ProductStandardCost as Unit_cost,
        OrderQuantity,
        (ProductStandardCost*OrderQuantity) as Production_cost
from fact_sales;
/* End Q-5---------------------------*/
/*6.Calculate the profit.*/
 Select 
		(UnitPrice*OrderQuantity)*(1-UnitPriceDiscountPct) as Sales_Amount,
        (ProductStandardCost*OrderQuantity) as Production_cost,
        (UnitPrice*OrderQuantity)*(1-UnitPriceDiscountPct)-(ProductStandardCost*OrderQuantity) as Profit
from fact_sales;    
/* ----------End Q-6----------*/

/* Q-7 write a query for month and sales (provide the Year as filter to select a particular Year
select * from fact_sales;

SELECT 
	Year(OrderDateKey1) as Year,
    MONTHNAME(OrderDateKey1) AS MonthName,
    SUM(SalesAmount) AS TotalSales
FROM fact_sales
-- This WHERE clause acts as your Pivot Table "Filter"
WHERE YEAR(OrderDateKey1) = 2011  
GROUP BY MONTH(OrderDateKey1), MONTHNAME(OrderDateKey1),Year
ORDER BY MONTH(OrderDateKey1); -- Ensures January comes before February, not alphabetical    
/*----------End Q-7--------*/

/*8.Write a Query to show yearwise Sales*/

select * from fact_sales;
select
		Year(OrderDateKey1) as Year,
        sum(SalesAmount) as Total_Sales
from fact_sales
group by Year
order by Year ;       
/*---------End Q-8----------*/
/*9.Write a query to show Monthwise sales*/
select
	monthname(orderdatekey1) as Month_Name,
    sum(SalesAmount) as Total_Sales
from fact_sales
Group by Month(orderdatekey1),Month_Name
order by Month(orderdatekey1);
/*-------------Q-9 End-----------*/
/*10.Write a query to show Quarterwise sales */
/*select
		year(orderdatekey1) as Sales_year,
		concat('Q',(orderdatekey1)) as salesQuarter ,
        sum(salesamount) as Total_sales
from fact_sales
group by 
		year(orderdatekey1),
        Quarter(orderdatekey1)
order by 
		Sales_Year,
        Quarter(Orderdatekey1); */
SELECT 
    YEAR(Orderdatekey1) AS SalesYear,
    
    SUM(CASE WHEN QUARTER(Orderdatekey1) = 1 THEN SalesAmount ELSE 0 END) AS Q1_Sales,
    SUM(CASE WHEN QUARTER(Orderdatekey1) = 2 THEN SalesAmount ELSE 0 END) AS Q2_Sales,
    SUM(CASE WHEN QUARTER(Orderdatekey1) = 3 THEN SalesAmount ELSE 0 END) AS Q3_Sales,
    SUM(CASE WHEN QUARTER(Orderdatekey1) = 4 THEN SalesAmount ELSE 0 END) AS Q4_Sales,
    SUM(SalesAmount) AS Yearly_Grand_Total
FROM fact_sales
GROUP BY 
    YEAR(Orderdatekey1)
ORDER BY 
    SalesYear;  
/* ----------End Q-10--------*/
/*11.Write a query  to show Salesamount and Productioncost along with year and month name together*/
SELECT 
    DATE_FORMAT(Orderdatekey1, '%Y-%b') AS YearMonth,
    SUM(SalesAmount) AS Total_Sales,
    SUM(TotalProductCost) AS Total_Production_Cost
FROM fact_sales
GROUP BY 
    YEAR(Orderdatekey1), 
    MONTH(Orderdatekey1),
    DATE_FORMAT(Orderdatekey1, '%Y-%b')
ORDER BY 
    YEAR(Orderdatekey1), 
    MONTH(Orderdatekey1);    
        
        
        



  

  



