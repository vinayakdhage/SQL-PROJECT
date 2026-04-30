-- CREATE TABLE swiggy_db
CREATE TABLE swiggy_db (
    state TEXT,
    city TEXT,
    order_date DATE,
    restaurant_name TEXT,
    location TEXT,
    category TEXT,
    dish_name TEXT,
    price_inr NUMERIC,
    rating NUMERIC,
    rating_count numeric
);
 
select*from swiggy_db
--data validation and cleaning
--null check

select 
    sum(case when state is null then 1 else 0 end) as null_state,
	sum(case when city is null then 1 else 0 end) as null_city,
	sum(case when order_date is null then 1 else 0 end) as null_date,
	sum(case when restaurant_name is null then 1 else 0 end) as null_resturant_name,
	sum(case when location is null then 1 else 0 end) as null_location,
	sum(case when category is null then 1 else 0 end) as null_category,
	sum(case when dish_name is null then 1 else 0 end) as null_dish_name,
	sum(case when price_inr is null then 1 else 0 end) as null_price,
	sum(case when rating is null then 1 else 0 end) as null_rating,
	sum(case when rating_count is null then 1 else 0 end) as null_rating_count
from swiggy_db
	
 

--blank or empty string
select*
from swiggy_db where
state='' or city='' or order_date is null or restaurant_name='' or location='' or dish_name=''
or price_inr is null or rating is null or rating_count is null

 

--duplicate detaction
select state, city, order_date, restaurant_name,location, category, 
dish_name, price_inr, rating, rating_count, count(*) as cnt  from
swiggy_db
group by 1,2,3,4,5,6,7,8,9,10
having count(*)>1
 

-- delete duplicate 

WITH cte AS (
    SELECT ctid,
          ROW_NUMBER() OVER (
               PARTITION BY state, city, order_date, restaurant_name, location, category, 
                            dish_name, price_inr, rating, rating_count
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM swiggy_db
)
--select* from cte where rn>1
 


DELETE FROM swiggy_db
WHERE ctid IN (
    SELECT ctid FROM cte WHERE rn > 1
)
 

-- creating schema
--dim table
-- date table
create table dim_date(
          date_id SERIAL primary key,
		  full_date date,
		  year int,
		  month int,
		  month_name varchar(20),
		  quarter int,
		  day int,
		  week int
)
select* from dim_date

-- dim_location 
create table dim_loc(
    location_id serial primary key,
	state varchar(100),
	city varchar(100),
	location varchar(200)
)


--dim_restaurant
create table dim_restaurant(
       restaurant_id serial primary key,
	   restaurant_name varchar(200)
)
select*from dim_restaurant

--dim_category
create table dim_category(
        category_id serial primary key,
		category varchar(200)
)
select * from dim_category

--dim_dish
create table dim_dish(
        dish_id serial primary key,
		dish_name varchar(200)
)
select*from dim_dish

-- fact table
create table swiggy_orders(
      order_id serial primary key,
	  date_id  int,
	  price_inr decimal(10,2),
	  rating decimal(4,2),
	  rating_count int,

	  location_id int,
	   restaurant_id int,
	  category_id int,
	  dish_id int,

	  foreign key (date_id) references dim_date(date_id),
	  foreign key (location_id) references dim_loc(location_id),
	  foreign key (restaurant_id) references dim_restaurant( restaurant_id),
	  foreign key (category_id) references dim_category(category_id),
	  foreign key (dish_id) references dim_dish(dish_id)
)
select*from swiggy_orders

--insert data in table
--dim_date
insert into dim_date(full_date, year, month,month_name, quarter, day, week )
select distinct
     order_date,
	 extract(year from order_date),
	 extract(month from order_date),
	 to_char(order_date,'month'),
	 extract(quarter from order_date),
	 extract(day from order_date),
	 extract(week from order_date)
from swiggy_db
where order_date is not null

select*from dim_date
 
 

--insert in location 
insert into dim_loc(state,city,location)
select distinct
        state,
		city,
		location
from swiggy_db
select*from dim_loc
  

--insert in restaurant
insert into dim_restaurant(restaurant_name)
select distinct
       restaurant_name
from swiggy_db
select*from dim_restaurant
  

-- insert in category
insert into dim_category(category)
select distinct
        category
from swiggy_db
select*from dim_category
  

--insert in dish
insert into dim_dish(dish_name)
select distinct
      dish_name
from swiggy_db
select*from dim_dish
  

--insert in fact-swiggy_order
insert into swiggy_orders(
	  date_id,
	  price_inr ,
	  rating ,
	  rating_count ,

	  location_id ,
	   restaurant_id ,
	  category_id ,
	  dish_id )
select 
     dd.date_id,
	 s.price_inr,
	 s.rating,
	 s.rating_count,
	 dl.location_id,
	 dr.restaurant_id,
	 dc.category_id,
	 dsh.dish_id
from swiggy_db as s
join dim_date as dd on s.order_date=dd.full_date
join dim_loc as dl on s.state=dl.state and s.city=dl.city and s.location=dl.location
join dim_restaurant as dr on dr.restaurant_name=s.restaurant_name
join dim_category as dc on dc.category= s.category
join dim_dish as dsh on dsh.dish_name=s.dish_name
select*from swiggy_orders
  

select*from swiggy_orders as so
join dim_date as dd on dd.date_id=so.date_id
join dim_loc as dl on dl.location_id=so.location_id
join dim_restaurant as dr on dr.restaurant_id=so.restaurant_id
join dim_category as dc on dc.category_id=so.category_id
join dim_dish as dsh on dsh.dish_id=so.dish_id
  
    

--KPI's
--total orders
select count(*) as total_orders
from swiggy_orders
  

--total revenue(INR MILLION)
SELECT 
    ROUND(SUM(price_inr)::NUMERIC / 1000000, 2) || ' INR million' AS total_revenue
FROM swiggy_orders
  

--average dish_price
select 
     round(avg(price_inr),2) ||' INR' as avg_price
from swiggy_orders
  

--avrage rating
select
     round(avg(rating),2) as avg_rating
from swiggy_orders
  

--deep-dive business analysis
--monthly order trend
select
d.year,d.month,d.month_name, count(*)as total_orders
from swiggy_orders as so
join dim_date as d on d.date_id=so.date_id
group by 1,2,3
order by 4 desc
  



--total revenue
select
d.year,d.month,d.month_name, ROUND(SUM(price_inr)::NUMERIC / 1000000, 2) 
                                     || ' INR million' AS total_revenue
from swiggy_orders as so
join dim_date as d on d.date_id=so.date_id
group by 1,2,3
order by 4 desc
  

--quarterly trend
select
d.year,d.quarter, count(*)as total_orders
from swiggy_orders as so
join dim_date as d on d.date_id=so.date_id
group by 1,2
order by 3 desc
  

--total_revenue by quarter
select
d.year,d.quarter, ROUND(SUM(price_inr)::NUMERIC / 1000000, 2) 
                                     || ' INR million' AS total_revenue
from swiggy_orders as so
join dim_date as d on d.date_id=so.date_id
group by 1,2
order by 3 desc
  

--Orders by dayof week(mon-sun)
select
     to_char(d.full_date,'day') as day_name,
	 count(*) as total_Orders
from swiggy_orders as so
join dim_date as d on d.date_id=so.date_id
group by 1
  

--top 10 cities by order volume
select
l.city, count(*) as total_order
from swiggy_orders as so
join dim_loc as l on l.location_id=so.location_id
group by 1
order by 2 desc
limit 10
 
 

--sum of sale by top 10 city
select 
l.city, round(sum(price_inr)/1000000,2) || ' INR millian'as total_revenue
from swiggy_orders as so
join dim_loc as l on l.location_id=so.location_id
group by 1
order by 2 desc
limit 10
  

-- total revenue by state
select
l.state, round(sum(price_inr)/1000000,2) || ' INR millian'as total_revenue
from swiggy_orders as so
join dim_loc as l on l.location_id=so.location_id
group by 1
order by 2 desc
limit 10
  

--top10 restaurant by order
select 
r.restaurant_name, count(*)as total_order
from swiggy_orders as so
join dim_restaurant as r on r.restaurant_id=so.restaurant_id
group by 1
order by 2 desc
limit 10
  

--top10 rest. by revenue
select 
r.restaurant_name, round(sum(price_inr)/1000000,2) || ' INR millian' as total_revenue
from swiggy_orders as so
join dim_restaurant as r on r.restaurant_id=so.restaurant_id
group by 1
order by 2 desc 
limit 10
  

-- by category wise total_order
select
c.category, count(*) as total_orders
from swiggy_orders as so
join dim_category as c on c. category_id= so.category_id
group by 1
order by 2 desc
  

-- by category wise total revenue
select 
c.category, round(sum(price_inr)/100000,2) || ' INR lac' as total_revenue
from swiggy_orders as so
join dim_category as c on c.category_id=so.category_id
group by 1
order by 2 desc 
  

-- best dish by order
select 
d.dish_name, count(*) as total_orders
from swiggy_orders as so
join dim_dish as d on d.dish_id=so.dish_id
group by 1
order by 2 desc
 
 


-- dish by total revenue
select 
d.dish_name, round(sum(price_inr),2) || ' INR' as total_revenue
from swiggy_orders as so
join dim_dish as d on d.dish_id=so.dish_id
group by 1
order by 2 desc
 
 


