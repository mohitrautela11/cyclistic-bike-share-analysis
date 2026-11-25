DROP TABLE IF EXISTS dbo.trips_clean;
GO

-- 1. Create the clean, strongly-typed production table with PRIMARY KEY
CREATE TABLE dbo.trips_clean (
    ride_id VARCHAR(25) NOT NULL PRIMARY KEY,
    rideable_type VARCHAR(30) NOT NULL,
    started_at DATETIME2(0) NOT NULL,
    ended_at DATETIME2(0) NOT NULL,
    ride_length_sec INT NOT NULL,
    ride_length_min DECIMAL(10, 2) NOT NULL,
    day_of_week INT NOT NULL,          -- 1 = Sunday ... 7 = Saturday (matching brief)
    day_name VARCHAR(15) NOT NULL,
    month_num INT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    start_hour INT NOT NULL,
    start_station_name VARCHAR(255) NOT NULL,
    end_station_name VARCHAR(255) NOT NULL,
    start_lat FLOAT NULL,
    start_lng FLOAT NULL,
    end_lat FLOAT NULL,
    end_lng FLOAT NULL,
    member_casual VARCHAR(20) NOT NULL
);
GO


-- 2. Strip quotes, deduplicate, filter invalid durations, and insert into trips_clean
WITH CleanedRaw AS (
    SELECT 
        LTRIM(RTRIM(REPLACE(ride_id, '"', ''))) AS ride_id,
        LTRIM(RTRIM(REPLACE(rideable_type, '"', ''))) AS rideable_type,
        TRY_CAST(REPLACE(started_at, '"', '') AS DATETIME2(0)) AS started_at,
        TRY_CAST(REPLACE(ended_at, '"', '') AS DATETIME2(0)) AS ended_at,
        COALESCE(NULLIF(LTRIM(RTRIM(REPLACE(start_station_name, '"', ''))), ''), 'On-Street / No Station') AS start_station_name,
        COALESCE(NULLIF(LTRIM(RTRIM(REPLACE(end_station_name, '"', ''))), ''), 'On-Street / No Station') AS end_station_name,
        TRY_CAST(REPLACE(start_lat, '"', '') AS FLOAT) AS start_lat,
        TRY_CAST(REPLACE(start_lng, '"', '') AS FLOAT) AS start_lng,
        TRY_CAST(REPLACE(end_lat, '"', '') AS FLOAT) AS end_lat,
        TRY_CAST(REPLACE(end_lng, '"', '') AS FLOAT) AS end_lng,
        LTRIM(RTRIM(REPLACE(member_casual, '"', ''))) AS member_casual,
        ROW_NUMBER() OVER (
            PARTITION BY LTRIM(RTRIM(REPLACE(ride_id, '"', ''))) 
            ORDER BY TRY_CAST(REPLACE(started_at, '"', '') AS DATETIME2(0))
        ) AS rn
    FROM dbo.trips_raw
)
INSERT INTO dbo.trips_clean (
    ride_id, rideable_type, started_at, ended_at,
    ride_length_sec, ride_length_min, day_of_week, day_name,
    month_num, month_name, start_hour,
    start_station_name, end_station_name,
    start_lat, start_lng, end_lat, end_lng, member_casual
)
SELECT 
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    DATEDIFF(SECOND, started_at, ended_at) AS ride_length_sec,
    CAST(DATEDIFF(SECOND, started_at, ended_at) / 60.0 AS DECIMAL(10, 2)) AS ride_length_min,
    DATEPART(WEEKDAY, started_at) AS day_of_week,
    DATENAME(WEEKDAY, started_at) AS day_name,
    MONTH(started_at) AS month_num,
    DATENAME(MONTH, started_at) AS month_name,
    DATEPART(HOUR, started_at) AS start_hour,
    start_station_name,
    end_station_name,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM CleanedRaw
WHERE rn = 1                                                          -- Remove 35 duplicates
  AND started_at IS NOT NULL 
  AND ended_at IS NOT NULL
  AND DATEDIFF(SECOND, started_at, ended_at) >= 60                    -- Remove <= 0 sec & < 1 min false starts
  AND DATEDIFF(SECOND, started_at, ended_at) <= 86400;                -- Remove > 24 hour outliers
GO

--3. Verify final clean row count and confirm exact rows removed
SELECT 
    (SELECT COUNT(*) FROM dbo.trips_raw) AS raw_rows,
    COUNT(*) AS clean_rows,
    (SELECT COUNT(*) FROM dbo.trips_raw) - COUNT(*) AS total_rows_removed
FROM dbo.trips_clean;