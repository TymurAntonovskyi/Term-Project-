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
![Structure](https://lh4.googleusercontent.com/Ix-as6d99mUfQPWO-OtD_BL-uowIMe92xpWB2v7LjpnInz_Z7BiYXuSvHxjXSc6l2SkcYHI1gqJDAGRkOFVM=w1366-h568)

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
Aims to analyse the distribution of values in dataset and identify trends.
```sql
Select Store,avg(CPI) as AVG_CPI from features 
GROUP BY Store
ORDER BY avg(CPI) desc ; 
```
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

```sql
Select Store, avg(Fuel_Price) as AVG_FuelPrice from features 
GROUP BY Store
ORDER BY avg(Fuel_Price) desc ; 
```


```sql
Select YEAR(Date_N),Month(Date_N), sum(Total_MarkDown)
FROM features 
Group by YEAR(Date_N),Month(Date_N)
Order by Total_MarkDown desc;
```

As a result, the following statements can be highlighted:
1.  Shops 2 and 4 provided the biggest amount of discounts during the period.
2. The price of Fuel in all regions is approximately the same
3. The Unemployment rate in the 2 regions(2nd Shop), while the Consumer Price Index is above average.
4. The biggest MarkDowns among shops were available in February during the SuperBowl championship.
