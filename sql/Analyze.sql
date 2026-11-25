-- 1. Overall Ride Volume & Ride Length (Mean, Min, Max) by User Type
SELECT 
    member_casual,
    COUNT(*) AS total_rides,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5, 2)) AS pct_of_total_rides,
    CAST(AVG(ride_length_min) AS DECIMAL(10, 2)) AS avg_ride_length_min,
    MIN(ride_length_min) AS min_ride_length_min,
    MAX(ride_length_min) AS max_ride_length_min
FROM dbo.trips_clean
GROUP BY member_casual;

-- 2. Day of Week Trends (Volume & Avg Duration: 1=Sunday ... 7=Saturday)
SELECT 
    member_casual,
    day_of_week,
    day_name,
    COUNT(*) AS total_rides,
    CAST(AVG(ride_length_min) AS DECIMAL(10, 2)) AS avg_ride_length_min
FROM dbo.trips_clean
GROUP BY member_casual, day_of_week, day_name
ORDER BY member_casual, day_of_week;

-- 3. Monthly / Seasonal Trends (Nov 2025 - Oct 2026)
SELECT 
    YEAR(started_at) AS trip_year,
    month_num,
    month_name,
    member_casual,
    COUNT(*) AS total_rides,
    CAST(AVG(ride_length_min) AS DECIMAL(10, 2)) AS avg_ride_length_min
FROM dbo.trips_clean
GROUP BY YEAR(started_at), month_num, month_name, member_casual
ORDER BY trip_year, month_num, member_casual;

-- 4. Hourly Commute vs. Leisure Patterns (0 to 23)
SELECT 
    start_hour,
    member_casual,
    COUNT(*) AS total_rides
FROM dbo.trips_clean
GROUP BY start_hour, member_casual
ORDER BY start_hour, member_casual;

-- 5. Bike Type Preference (Classic vs. Electric)
SELECT 
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    CAST(AVG(ride_length_min) AS DECIMAL(10, 2)) AS avg_ride_length_min
FROM dbo.trips_clean
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;