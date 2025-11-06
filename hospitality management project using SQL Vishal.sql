CREATE DATABASE hospitality_analysis;
Use hospitality_analysis;

SELECT * FROM dim_date;
SELECT * FROM dim_hotels;
SELECT * FROM dim_rooms;
SELECT * FROM fact_aggregated_bookings;
SELECT * FROM fact_bookings;

# TOTAL REVENUE
SELECT concat((sum(revenue_realized)/1000000),"M") AS total_revenue 
FROM fact_bookings;

# TOTAL BOOKINGS
SELECT count(distinct booking_id) AS total_bookings
FROM fact_bookings;

# OCCUPANCY RATE
SELECT (sum(successful_bookings)/sum(capacity)) * 100 
FROM fact_aggregated_bookings;

# CANCELLATION RATE
SELECT (count( 
		CASE WHEN booking_status = "cancelled" THEN 1 END) /
        count(*)) *100  AS cancellation_rate
FROM fact_bookings;

# MONTH WISE REVENUE
SELECT monthname(booking_date) AS month, 
	   concat((sum(revenue_realized)/1000000),"M") AS Revenue
FROM fact_bookings
Group by month;


# WEEKLY REVENUE
SELECT `week no` , sum(revenue_realized) AS Total_revenue
FROM dim_date d
JOIN fact_bookings f 
ON d.date = f.booking_date
GROUP BY `week no`;

# WEEKLY BOOKINGS
SELECT `week no` ,count(f.booking_id) as total_bookings
FROM dim_date d
JOIN fact_bookings f 
ON d.date = f.booking_date
GROUP BY `week no`
ORDER BY `week no`;


# MONTHLY BOOKINGS
SELECT monthname(booking_date) AS month,
			count(booking_id) AS bookings
FROM fact_bookings
GROUP BY month;

# monthly REVENUE PER ROOM
SELECT monthname(f.check_in_date) AS months,
	   f.property_id,
       sum(f.successful_bookings) AS total_bookings,
       sum(b.total_revenue) AS total_revenue,
       round(sum(b.total_revenue)/sum(f.successful_bookings),2) AS revenue_per_room
FROM fact_aggregated_bookings f
JOIN (SELECT property_id,
			   check_in_date,
               room_category,
               sum(revenue_realized) AS total_revenue
		FROM fact_bookings 
        GROUP BY property_id, check_in_date, room_category) AS b
ON f.property_id = b.property_id
AND f.check_in_date = b.check_in_date
ANd f.room_category = b.room_category
GROUP BY monthname(f.check_in_date),f.property_id;


# WEEKDAY & WEEKEND REVENUE

SELECT d.day_type, sum(r.revenue_realized) AS total_revenue
FROM fact_bookings r
JOIN dim_date d
ON d.date = r.booking_date
GROUP BY day_type;

# Revenue by state & hotel
SELECT d.property_name AS Hotels, concat((sum(f.revenue_realized)/1000000),"M") AS Total_revenue
FROM dim_hotels d
JOIN fact_bookings f                                                               -- REVENUE BY HOTELS --
ON d.property_id = f.property_id
GROUP BY property_name;

SELECT d.city, concat((sum(f.revenue_realized)/1000000),"M") AS Total_revenue
FROM dim_hotels d
JOIN fact_bookings f																	-- REVENUE BY CITY --
ON d.property_id = f.property_id
GROUP BY d.city
ORDER BY Total_revenue DESC;


# REVENUE BY ROOM CLASS
SELECT d.room_class, concat((sum(f.revenue_realized)/1000000),"M") AS Total_revenue
FROM dim_rooms d
JOIN fact_bookings f
ON d.room_id = f.room_category
GROUP BY d.room_class;

# % of booking status
SELECT
  booking_status,
  COUNT(*) AS total_bookings,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM fact_bookings
GROUP BY booking_status;


# TOTAL BOOKING AND REVENUE BY PLATFORMS
SELECT booking_platform , 
	   count(booking_id) AS Total_bookings, 
       concat((sum(revenue_realized)/1000000)," ","M") AS Total_revenue
FROM fact_bookings
GROUP BY booking_platform
ORDER BY total_bookings DESC;

# AVG RATINGS FOR EACH ROOM TYPE
SELECT d.room_class, 
		round(avg(f.ratings_given),1) AS avg_rating
FROM dim_rooms d
JOIN fact_bookings f
ON d.room_id = f.room_category
WHERE ratings_given > 0
GROUP BY d.room_class;


