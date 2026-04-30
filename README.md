Swiggy Sales Analysis Project:

  Swiggy Sales Data Analysis using SQL (Data Cleaning + Data Modeling + Business Insights)

1.Project Overview-
   This project focuses on analyzing Swiggy food delivery data to extract meaningful business insights.
  It includes data cleaning, transformation, dimensional modeling, and advanced SQL analysis.

2. Objectives-
  - Perform data validation and cleaning
  - Build a star schema data model
  - Calculate key business KPIs
  - Analyze sales trends and performance
  - Identify top-performing cities, restaurants, and dishes

3. Dataset Details-
  Location data (State, City, Area),Restaurant details,Dish and category,Order date,Price, rating, and rating count

4. Data Cleaning Steps-
 - Handled NULL values
 - Removed duplicate records using CTE & ROW_NUMBER()
 - Checked for blank and inconsistent data
 - Ensured proper data types

5. Data Modeling-
   Fact Table:
     swiggy_orders
   Dimension Tables:
     dim_date
     dim_loc
     dim_restaurant
     dim_category
     dim_dish
 
 6. Key KPIs
  - Total Orders
  - Total Revenue
  - Average Order Value
  - Average Rating

7. Business Insights
  - Monthly and quarterly order trends
  - Top 10 cities by order volume and revenue
  - Top restaurants based on performance
  - Category-wise demand analysis
  - Most popular dishes
