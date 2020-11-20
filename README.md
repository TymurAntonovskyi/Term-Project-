# Term Project 
[Link for original dataset](https://www.kaggle.com/manjeetsingh/retaildataset)

### Content

You are provided with historical sales data for 45 stores located in different regions - each store contains a number of departments. The company also runs several promotional markdown events throughout the year. These markdowns precede prominent holidays, the four largest of which are the Super Bowl, Labor Day, Thanksgiving, and Christmas. The weeks including these holidays are weighted five times higher in the evaluation than non-holiday weeks.
Within the Excel Sheet, there are 3 Tabs – Stores, Features and Sales

#### Stores

Anonymized information about the 45 stores, indicating the type and size of store

#### Features
Contains additional data related to the store, department, and regional activity for the given dates.

 - Store - the store number
 - Date - the week
 - Temperature - average temperature in the region
 - Fuel_Price - cost of fuel in the region
 - MarkDown1-5 - anonymized data related to promotional markdowns. MarkDown data is only available after Nov 2011, and is not available for all stores all the time. Any missing value is marked with an NA
 - CPI - the consumer price index
 - Unemployment - the unemployment rate
 - IsHoliday - whether the week is a special holiday week
#### Sales
Historical sales data, which covers to 2010-02-05 to 2012-11-01. Within this tab you will find the following fields:

 - Store - the store number
 - Dept - the department number
 - Date - the week
 - Weekly_Sales -  sales for the given department in the given store
 - IsHoliday - whether the week is a special holiday week
 
 
 ### Aim of the analysis 
 The aim of this work is to analyze the reltionship betwwen the TotalValue of MarkDowns in 5 different shops and The total amont of sales. Along with it, aim is to check how other variables may influance the Weekly_Sales in each shop.

### Database structure 
![Structure](https://github.com/TymurAntonovskyi/Term-Project-/blob/main/Scheme.PNG)

### Create Schema 
```sql
CREATE SCHEMA project;
USE project;  
```

### Table Creation 
Operational data layer 

#### Features table
```sql
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
```
Use the following link for accessing data for features table
[Features.csv](https://github.com/TymurAntonovskyi/Term-Project-/blob/main/Featuresdata.csv)

##### Load data to Features table
```sql
LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Featuresdata.csv'  
INTO TABLE features 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES ;  
```


#### Sales Table
```sql
USE project; 
CREATE TABLE Sales
(ID INTEGER PRIMARY KEY NOT NULL,
Store INTEGER NOT NULL,
Date_N DATE NOT NULL,
Weekly_Sales INTEGER NOT NULL,
IsHoliday INTEGER); 
```
Use the following link for accessing data for sales table
[Sales.csv](https://github.com/TymurAntonovskyi/Term-Project-/blob/main/Salesdata.csv)

##### Load data to Sales table
```sql
LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Salesdata.csv'  
INTO TABLE sales 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES ;
```

#### Stores table
```sql
USE project; 
CREATE TABLE Stores
(Store INTEGER PRIMARY KEY NOT NULL,
Type_N VARCHAR(16) NOT NULL,
Size INTEGER NOT NULL); 
```
Use the following link for accessing data for stores table
[Stores.csv](https://github.com/TymurAntonovskyi/Term-Project-/blob/main/Storesdata.csv)

##### Load data to Stores table
```sql
LOAD DATA INFILE 'c:/Program Files/MySQL/Uploads/Storesdata.csv'  
INTO TABLE Stores 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES ;
```

### Data adjustment
On Features table we have 5 different types of MarkDowns and their final value in each week. Unfortunately, there is no information about these markdowns so for a particular project there is no sense to store them independently. As a result, a new column(Total_MarkDown) was added.

```sql
ALTER TABLE features 
ADD Total_MarkDown INT AS ( MarkDown1 + MarkDown2 + MarkDown3 + MarkDown4 + MarkDown5) STORED;
```

### Data pre-testing
The aim of this section is to analyse the distribution of values in dataset and identify trends.

Aim: To identify the Consumer Price Index in each region
```sql
Select Store,avg(CPI) as AVG_CPI from features 
GROUP BY Store
ORDER BY avg(CPI) desc ; 
```

Aim: To identify the average level of Unemployment in each region
```sql
Select Store,avg(Unemployment) as AVG_Unemployment_Rate,
CASE 
WHEN avg(Unemployment) > 6.93217 THEN "Above Average"
WHEN avg(Unemployment) < 6.93217 THEN "Below Average"
END as Unemployment_lvl
 from features 
GROUP BY Store
ORDER BY avg(Unemployment) desc ; 
```

Aim: To check if Fuel Price is different in different Regions --
```sql
Select Store, avg(Fuel_Price) as AVG_FuelPrice from features 
GROUP BY Store
ORDER BY avg(Fuel_Price) desc ; 
```

Aim:To see sales tendency from 2010 until 2012 in each of the shops
```sql
sum( case when year(s.Date_N) = 2010 then Weekly_Sales end) as "2010",
sum( case when year(s.Date_N) = 2011 then Weekly_Sales end) as "2011",
sum( case when year(s.Date_N) = 2012 then Weekly_Sales end) as "2012"
from sales as s
group by store
order by Weekly_Sales desc;
```
```sql
Select avg(Weekly_Sales) from sales;
Select max(Weekly_Sales) from sales;
Select min(Weekly_Sales) from sales;

```
```sql
Select store,avg(Weekly_Sales), 
CASE
WHEN avg(Weekly_Sales) >= 21475 THEN "Bigger then AVG"
ELSE "Lower then AVG"
END as Comparison_With_AVG
from sales
Group by store
ORDER BY avg(Weekly_Sales) desc ;
```


As a result of pretesting,the following statements can be highlighted:
1. The price of Fuel in all regions is approximately the same.
2. The Unemployment rate is the biggest in the 2 regions(2nd Shop) and the Consumer Price Index is above average.
3. The introduction of discount policy in shops had ambiguous effect on sales.
4.Sales in shops number 4,2 and 1 were bigger compare average sales in all regions.



## Analytical layer 
For the following analysis variable, like: ID, Weekly_Sales, Total_MarkDown, Store, Data_N, CPI, Is_Holiday and Type_N were joined together for the following analysis.
The factor is Weekly Sales, while Total_MarkDown and CPI related to dimension 1, Data_N and Is_Holiday relate to dimension 2, Type_N is dimension 3.
The following table will be used for the further analysis of data.

```sql
select f.ID,s.Weekly_Sales,f.Total_MarkDown,f.Store,f.Date_N as Date,f.CPI,f.IsHoliday,st.Type_N as Store_Type,
CASE
WHEN st.Type_N = "A" THEN "Big"
WHEN st.Type_N = "B" THEN "Small"
END AS Shop_Size 
from features as f
INNER join sales as s
USING(ID)
INNER JOIN stores as st
Where s.Store = st.Store
```
Results: The highers value 4 times bigger than the smaller values, also we can notice that shop 2 and 4 actively provide discounts  -- 
Also, we can see that the level of sales can be affected by the size of the shop. Shop number 3 and 5 had a much lower size compare to other shops.



Aim: To find exact dates and shops where were the biggerst Total MarkDown values
```sql
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
```
As we can observe: Shops 2 and 4 provided the biggest amount of discounts during the period.
The biggest MarkDowns among shops were available in February during the SuperBowl championship and during Christmas holidays. In the same time,total value of discounts also increased before and after other Holiday days but volume of discounts was lower.

```sql
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
```
Result: As it can be seen,there is not straight forward relationship between Sales and MarkDown policies.



Aim: To see the sales CPI before and after the introduction of Discount policies in each shop.
```sql
Select YEAR(Date_N) as Year, sum(Total_MarkDown) as Total_MarkDown , sum(Weekly_Sales) as Yearly_Sales ,avg(k.CPI) as AVG_CPI
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
```
As we can see the total sales increased at the end of 2011 when MarkDowns policies were implemented.


Aim: To see sales in each year, considering the equal amount of months. In particular dataset the historical data about discount policy distributed and available unequally. The data about sales during discount available until October of 2012. 
```sql
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
```




Aim: Compare Total Sales in February 2010(without discounts) and in February 2012 (after introduction of the discounts). In February there is SuperBowl championship and as it was mention previously there a huge volume of sales in the shops.
```sql
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
```

As we can see, shop number 2 and 4, which provided the biggest amount of sales, also the biggest shops in therm of area and shelves space. Potentially, the size of the shop can have a strong influence on sales since they can provide a variety of different product, thereby fulfilling needs and wants of different customers segments. The relationship between a dependent variable and independent variables will be calculated with the help correlation in the following section.

### Stored proceders

```sql
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
```

Aim: Retriew weekly sales in particular shop in specified date.
Input: Store number(1-5),date("YYYY-MM-DD")
```sql
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
```
### Views

View 1: Shows the Sales for 2 shop in 2012.
```sql
DROP VIEW IF EXISTS MonthlySales_Store2;
CREATE VIEW `MonthlySales_Store2_2012` AS
SELECT * FROM sales WHERE store = 2 and Year(Date_N)= 2012;
select * from `MonthlySales_Store2_2012`;
```
View 2: Shows the final version of combined tables
```sql
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
```
Call view 2 with the following query:
```sql
SELECT * FROM weekly_sales_view;
```



### Correlation

Calculation of correlation between Total MarkDown variable and Weekly_Sales
```sql
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


select @ax :=  avg(Total_MarkDown)  ,
		@ay :=  avg(Weekly_Sales) ,
       @cov :=  sum((c.Total_MarkDown - @ax) * (c.Weekly_Sales - @ay))/255  , 
        @stdx :=  sqrt( sum( (c.Total_MarkDown - @ax) * (c.Total_MarkDown - @ax) )/255 ) ,
        @stdy := sqrt(sum((c.Weekly_Sales - @ay) * (c.Weekly_Sales - @ay) )/ 255),
        @cor := @cov/((@stdx*@stdy))
from correlation_s_md c; 
```
Result: Correlation between Total MarkDown variable and Weekly_Sales is 33%. It menas that there is not strong correlation betwwen 2 particular variables.  



Calculation of correlation between Sales and Consumer Price Index 
```sql
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
        @stdx :=  sqrt( sum( (b.Weekly_Sales - @ax) * (b.Weekly_Sales - @ax) )/715 ) ,
        @stdy := sqrt(sum((b.CPI - @ay) * (b.CPI - @ay) )/ 715),
        @cor := @cov/((@stdx*@stdy))
from Correlation_Sales_CPI as b; 
```
Result: The correlation between Sales and Consumer Price Index = -51%. It means that sales decrease when the Consumer Price Index increase. We can observe the same in the real market since when the Consumer Price Index increase people can buy a lower bundle of good for a specified amount of money. 




