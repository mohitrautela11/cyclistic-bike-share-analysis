USE CyclisticDB;
GO

DROP TABLE IF EXISTS dbo.tableau_summary;
GO

SELECT 
    member_casual,
    rideable_type,
    YEAR(started_at) AS trip_year,
    month_num,
    month_name,
    day_of_week,
    day_name,
    start_hour,
    COUNT(*) AS total_rides,
    SUM(ride_length_min) AS total_ride_minutes,
    CAST(AVG(ride_length_min) AS DECIMAL(10, 2)) AS avg_ride_length_min
INTO dbo.tableau_summary
FROM dbo.trips_clean
WHERE NOT (YEAR(started_at) = 2025 AND month_num = 10) -- Exclude Oct 31 spillover rows
GROUP BY 
    member_casual, rideable_type, YEAR(started_at), 
    month_num, month_name, day_of_week, day_name, start_hour;
GO

-- Preview summary table size (should be ~4,000 rows—instantaneous in Tableau!)
SELECT COUNT(*) AS summary_rows FROM dbo.tableau_summary;
SELECT * FROM dbo.tableau_summary ORDER BY trip_year, month_num, day_of_week, start_hour;