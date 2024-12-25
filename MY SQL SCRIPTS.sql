#1-------Total Revenue-----
select sum(revenue_generated) as Revenue_generated from project.fact_bookings; 

#2-------Occupancy-------
SELECT 
    SUM(successful_bookings) AS total_successful_bookings,
    SUM(capacity) AS total_capacity,
    (SUM(successful_bookings) / SUM(capacity)) * 100 AS occupancy_rate
FROM 
   projects.fact_aggregated_bookings   
WHERE 
    capacity > 0;
    
 #3-------- cancellation Rate -------
select concat((count(case when booking_status = 'cancelled' then 1 end)* 100.0/count(*)),' %' ) as cancellation_percentage
from project.fact_bookings;

#4------------ Total Booking ---------------

select count(booking_id) as "Total Bookings" from project.fact_bookings; 

#5-----------Utilize Capacity-------------
select sum(capacity) as UtilizeCapacity from projects.fact_aggregated_bookings;

#6-----------Trend Analysis----------
-- Check the first few rows from fact_bookings
SELECT * FROM project.fact_bookings LIMIT 5;

-- Check the first few rows from fact_aggregated_bookings
SELECT * FROM projects.fact_aggregated_bookings LIMIT 5;

# Monthly Bookings Trend

SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS month,
    COUNT(*) AS total_bookings
FROM project.fact_bookings
GROUP BY month
ORDER BY month;

# Cancellation Trends

SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS month,
    COUNT(*) AS total_cancellations
FROM project.fact_bookings
WHERE booking_status = 'Cancelled'
GROUP BY month
ORDER BY month;


# Revenue Trend

SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS month,
    SUM(revenue_generated) AS total_revenue_generated,
    SUM(revenue_realized) AS total_revenue_realized
FROM project.fact_bookings
GROUP BY month
ORDER BY month;


# Aggregated Bookings Comparison

SELECT 
    f.month,
    f.total_bookings,
    a.total_successful_bookings
FROM (SELECT DATE_FORMAT(booking_date, '%Y-%m') AS month,COUNT(*) AS total_bookings FROM project.fact_bookings GROUP BY month) f
JOIN (SELECT DATE_FORMAT(STR_TO_DATE(check_in_date, '%d-%b-%y'), '%Y-%m') AS month,SUM(successful_bookings) AS total_successful_bookings
    FROM projects.fact_aggregated_bookings GROUP BY month) a
ON f.month = a.month
ORDER BY f.month;


#7------weekday and weekend revenue and booking------
SELECT 
   COUNT(*) AS total_bookings,
    SUM(CASE WHEN DAYOFWEEK(check_in_date) IN (2, 3, 4, 5, 6) THEN revenue_generated ELSE 0 END) AS weekday_revenue,
    SUM(CASE WHEN DAYOFWEEK(check_in_date) IN (1, 7) THEN revenue_generated ELSE 0 END) AS weekend_revenue
FROM project.fact_bookings;

#8---------Revenue by state & hotel----------

SELECT 
    dh.city AS state,  -- Using 'city' as state or location
    dh.property_name AS hotel_name,
    SUM(fb.revenue_generated) AS total_revenue_generated,
    SUM(fb.revenue_realized) AS total_revenue_realized
FROM project.fact_bookings fb
JOIN projectss.dim_hotels dh
ON fb.property_id = dh.property_id
GROUP BY dh.city, dh.property_name
ORDER BY dh.city, total_revenue_generated DESC;



#9------------ Class Wise Revenue-----------------------------

select room_class,sum(revenue_generated) as Revenue_Generated
from project.fact_bookings
join dim_rooms on  
dim_rooms.room_id = fact_bookings.room_category
group by room_class
order by Revenue_Generated desc;

#10--------checked out cancel no show-------

SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS month,
    SUM(CASE WHEN booking_status = 'Checked Out' THEN 1 ELSE 0 END) AS total_checked_out,
    SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS total_cancelled,
    SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) AS total_no_show
FROM project.fact_bookings
GROUP BY month
ORDER BY month;

#11--------weekly trend key trend-------

SELECT 
    COUNT(booking_id) AS total_bookings,
    SUM(revenue_generated) AS total_revenue_generated,
    SUM(revenue_realized) AS total_revenue_realized,
    SUM(no_guests) AS total_guests
FROM project.fact_bookings;













