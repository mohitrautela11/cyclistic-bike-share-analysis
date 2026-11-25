SELECT 
    COUNT(*) AS total_raw_rows,
    COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_ride_ids,
    SUM(CASE WHEN started_at IS NULL OR ended_at IS NULL THEN 1 ELSE 0 END) AS missing_timestamps,
    SUM(CASE WHEN TRY_CAST(REPLACE(ended_at, '"', '') AS DATETIME2) <= TRY_CAST(REPLACE(started_at, '"', '') AS DATETIME2) THEN 1 ELSE 0 END) AS zero_or_negative_duration,
    SUM(CASE WHEN DATEDIFF(SECOND, TRY_CAST(REPLACE(started_at, '"', '') AS DATETIME2), TRY_CAST(REPLACE(ended_at, '"', '') AS DATETIME2)) > 86400 THEN 1 ELSE 0 END) AS over_24_hours,
    SUM(CASE WHEN start_station_name IS NULL OR LTRIM(RTRIM(REPLACE(start_station_name, '"', ''))) = '' THEN 1 ELSE 0 END) AS missing_start_station,
    SUM(CASE WHEN end_station_name IS NULL OR LTRIM(RTRIM(REPLACE(end_station_name, '"', ''))) = '' THEN 1 ELSE 0 END) AS missing_end_station
FROM dbo.trips_raw;