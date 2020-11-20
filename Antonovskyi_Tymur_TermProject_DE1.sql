-- Tables creation and data-loading Process --
USE project; 
CREATE TABLE features 
( ID INTEGER PRIMARY KEY NOT NULL,
Store INTEGER NOT NULL,
Date_N DATE NOT NULL,
Temperature DECIMAL(4,2) NOT NULL,
Fuel_Price DECIMAL(3,2) NOT NULL,
MarkDown1 INTEGER NOT NULL,
MarkDown2 INTEGER NOT NULL,
MarkDown3 INTEGER NOT NULL,
MarkDown4 INTEGER NOT NULL,
MarkDown5 INTEGER NOT NULL,
CPI DECIMAL(5,2) NOT NULL ,
Unemployment DECIMAL(2,1) NOT NULL ,
IsHoliday INTEGER);  
describe features;


LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Featuresdata.csv'  
INTO TABLE features 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
;

USE project; 
CREATE TABLE Sales
(ID INTEGER PRIMARY KEY NOT NULL,
Store INTEGER NOT NULL,
Date_N DATE NOT NULL,
Weekly_Sales INTEGER NOT NULL,
IsHoliday INTEGER); 

LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Salesdata.csv'  
INTO TABLE sales 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
;

USE project; 
CREATE TABLE Stores
(Store INTEGER PRIMARY KEY NOT NULL,
Type_N VARCHAR(16) NOT NULL,
Size INTEGER NOT NULL
); 
describe Stores;

LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Storesdata.csv'  
INTO TABLE Stores 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
;

-- TRANSFORMING PROCESS -- 
ALTER TABLE features 
ADD Total_MarkDown INT AS ( MarkDown1 + MarkDown2 + MarkDown3 + MarkDown4 + MarkDown5) STORED;


-- Pre-testing Part aims to analyse the distribution of values--

-- Aim: To analyze CPI by stores,it is important to remember that each store located in different regions --
-- Result:  The lowerst Consumer Price Index was observed in 4 shops(regions) --
Select Store,avg(CPI) as AVG_CPI from features 
GROUP BY Store
ORDER BY avg(CPI) desc ; 

 --  Aim: To identify the average level of Unemployment in each region   --
 -- Result: The 2nd store had the highers Unemployment rate --
Select Store,avg(Unemployment) as AVG_Unemployment_Rate,
CASE 
WHEN avg(Unemployment) > 6.93217 THEN "Above Average"
WHEN avg(Unemployment) < 6.93217 THEN "Below Average"
END as Unemployment_lvl
 from features 
GROUP BY Store
ORDER BY avg(Unemployment) desc ; 


-- Aim: To check the Fuel Price in different Regions --
-- Result : The price is simillar --
Select Store, avg(Fuel_Price) as AVG_FuelPrice from features 
GROUP BY Store
ORDER BY avg(Fuel_Price) desc ; 

-- Aim: To see sales tendency during from 2010 untill 2012 in each of the shops --
select s.store,
sum( case when year(s.Date_N) = 2010 then Weekly_Sales end) as "2010",
sum( case when year(s.Date_N) = 2011 then Weekly_Sales end) as "2011",
sum( case when year(s.Date_N) = 2012 then Weekly_Sales end) as "2012"
from sales as s
group by store
order by Weekly_Sales desc;

-- Aim: To find average weekly sales among 5 stores -- 
-- Result: 21475 --
Select avg(Weekly_Sales) from sales;

-- Aim: To find max weekly sales among 5 stores -- 
-- Result: 91966 --
Select max(Weekly_Sales) from sales;

-- Aim: To find min weekly sales among 5 stores -- 
-- Result: 3441 --
-- Comment: Based on previous findings we can see that data are not equally distributed since there is big differance between Max,Min and AVG
Select min(Weekly_Sales) from sales;

-- Aim: To see average sales by store -- 
-- Result: Sales in shop 4,2,1 are bigger then Average sales in all regions --
-- Comment: We had the same order of shops when calculated the TotalMarkDown value -- 
Select store,avg(Weekly_Sales), 
CASE
WHEN avg(Weekly_Sales) >= 21475 THEN "Bigger then AVG"
ELSE "Lower then AVG"
END as Comparison_With_AVG
from sales
Group by store
ORDER BY avg(Weekly_Sales) desc ;




-- ANALYTICAL LAYER -- 

select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Date_N as Date ,f.CPI,f.IsHoliday,st.Type_N as Store_Type,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN f.store = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store;
 
  

-- Aim: To find exact dates and shops where were the biggerst Total MarkDown values --  
-- Result: the biggerst MorkDown by value was in the 2nd store on 1st Week of Februaty --
-- Result2: 2 and 4 shops provided very big amount of discounts during SuperBowl event, Cristmas and Thanks given day --  
-- Comment: 7th of February is SuperBowl event -- 
Select k.Store,k.Date_N,k.Total_MarkDown,k.Shop_Size from
(select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N,f.CPI,f.IsHoliday,st.Type_N,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store) as k
ORDER BY Total_MarkDown desc
LIMIT 10;


-- Aim: To check if there is relationship between MarkDown and Total Sales --
Select k.Store,Year(k.Date_N) as Year,Month(k.Date_N) as Month,sum(k.Total_MarkDown) as Total_MarkDown,sum(k.Weekly_Sales) as Weekly_Sales,k.Shop_Size
from (select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N,f.CPI,f.IsHoliday,st.Type_N,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store) as k
WHERE k.Date_N between "2012-01-06" and "2012-10-26"
GROUP BY k.Store,Year(k.Date_N),Month(k.Date_N),k.Shop_Size
ORDER BY k.Store,Year(k.Date_N),Month(k.Date_N) asc;


-- Result: We can see that in 2012 the sales increased while MarkDown policies were introduce, in the same time the CPI and Unempl decreased --  
Select YEAR(Date_N) as Year, sum(Total_MarkDown) as Total_MarkDown , sum(Weekly_Sales) as Weekly_Sales ,avg(k.CPI) as AVG_CPI, avg(k.Unemployment) as AVG_Unemployment
FROM 
(select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N,f.CPI,f.Unemployment,f.IsHoliday,st.Type_N,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store) as k
Group by YEAR(Date_N);


-- Aim: To see sales per each year considering equal amount of monthes in each year -- 
-- Result: Sales were higher in 2012(With MarcDowns) compare to previous year
Select YEAR(Date_N) as Year, sum(Total_MarkDown) as Total_MarkDown , sum(Weekly_Sales) as Weekly_Sales ,avg(k.CPI) as AVG_CPI, avg(k.Unemployment) as AVG_Unemployment
FROM 
(select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N,f.CPI,f.Unemployment,f.IsHoliday,st.Type_N,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store) as k
where Month(k.Date_N) in (1,2,3,4,5,6,7,8,9,10)
Group by YEAR(Date_N);


-- Aim: Compare value in 2 month before and after introduction of the discounts --
select p.Weekly_Sales, p.Total_MarkDown from (
select  s.ID, s.Weekly_Sales,f.Total_MarkDown
from features as f
INNER join sales as s
USING(ID)
WHERE YEAR(f.Date_N) in ("2010") 
AND Month(f.Date_N) in (2)) as p
WHERE p.Total_MarkDown = 0 
union all
Select p.Weekly_Sales, p.Total_MarkDown from (
select s.ID, s.Weekly_Sales,f.Total_MarkDown
from features as f
INNER join sales as s
USING(ID)
WHERE YEAR(f.Date_N) in ("2012") 
AND Month(f.Date_N) in (2)) as p
WHERE p.Total_MarkDown <> 0;



DROP PROCEDURE IF EXISTS GetAllProducts;

DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN
select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N as Date,f.CPI,f.IsHoliday,st.Type_N as Store_Type,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store; 
END //
DELIMITER ;
 CALL GetAllProducts()


DELIMITER $$

CREATE PROCEDURE GetSalesByStoreAndDate (
	IN  Store_Number INTEGER, Date_A Date, 
	OUT total INT
)
BEGIN
	select s.Weekly_Sales
    INTO total
    from sales as s
    Where s.Store = Store_Number
    and Date_N = Date_A; 
END$$
DELIMITER ;

CALL GetSalesByStoreAndDate(1,"2010-02-19", @total_sales);
SELECT @total_sales;

-- VIEWS --
DROP VIEW IF EXISTS MonthlySales_Store2;
CREATE VIEW `MonthlySales_Store2_2012` AS
SELECT * FROM sales WHERE store = 2 and Year(Date_N)= 2012;
select * from `MonthlySales_Store2_2012`;


DROP VIEW IF EXISTS weekly_sales_view;
CREATE VIEW weekly_sales_view
as select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,YEAR(f.Date_N),Month(f.Date_N),f.CPI,f.IsHoliday,st.Type_N,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store;

SELECT * FROM weekly_sales_view;


-- Correlation -- 

CREATE TABLE Correlation_S_MD SELECT
f.Total_MarkDown,s.Weekly_Sales 
from features as f
INNER JOIN sales as s
USING(ID)
where Total_MarkDown != 0;

Alter table correlation_s_md
MODIFY COLUMN Total_MarkDown DECIMAL;

Alter table correlation_s_md
MODIFY COLUMN Weekly_Sales DECIMAL;

describe correlation_s_md;
select * from correlation_s_md;


-- Result: 33% --
select @ax :=  avg(Total_MarkDown)  ,
		@ay :=  avg(Weekly_Sales) ,
       @cov :=  sum((c.Total_MarkDown - @ax) * (c.Weekly_Sales - @ay))/255  , 
        @stdx :=  sqrt( sum( (c.Total_MarkDown - @ax) * (c.Total_MarkDown - @ax) )/255 ) ,
        @stdy := sqrt(sum((c.Weekly_Sales - @ay) * (c.Weekly_Sales - @ay) )/ 255),
        @cor := @cov/((@stdx*@stdy))
from correlation_s_md c; 




CREATE TABLE Correlation_UNE_CPI SELECT
f.Unemployment,f.CPI 
from features as f;
select * from correlation_une_cpi;
describe Correlation_UNE_CPI;

-- Result Correlation = 1 -- 
select @ax :=  avg(Unemployment)  ,
		@ay :=  avg(CPI) ,
       @cov :=  sum((c.Unemployment - @ax) * (c.CPI - @ay))/715  , 
        @stdx :=  sqrt( sum( (c.Unemployment - @ax) * (c.Unemployment - @ax) )/715 ) ,
        @stdy := sqrt(sum((c.CPI - @ay) * (c.CPI - @ay) )/ 715),
        @cor := @cov/((@stdx*@stdy))
from Correlation_UNE_CPI as c; 


 
 
 CREATE TABLE Correlation_Sales_CPI SELECT
s.Weekly_Sales,f.CPI 
from features as f
INNER JOIN sales as s
USING(ID);
select * from Correlation_Sales_CPI;
Alter table Correlation_Sales_CPI
MODIFY COLUMN Weekly_Sales DECIMAL;
describe Correlation_Sales_CPI;
select * from Correlation_Sales_CPI;
 
select @ax :=  avg(Weekly_Sales)  ,
		@ay :=  avg(CPI) ,
       @cov :=  sum((b.Weekly_Sales - @ax) * (b.CPI - @ay))/715  , 
        @stdx :=  sqrt(sum( (b.Weekly_Sales - @ax) * (b.Weekly_Sales - @ax) )/715 ) ,
        @stdy := sqrt(sum((b.CPI - @ay) * (b.CPI - @ay))/ 715),
        @cor := @cov/(@stdx*@stdy)
from Correlation_Sales_CPI as b; 


