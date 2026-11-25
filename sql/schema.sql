CREATE DATABASE CyclisticDB;
GO

USE CyclisticDB;
GO

CREATE TABLE dbo.trips_raw (
    ride_id VARCHAR(100),
    rideable_type VARCHAR(50),
    started_at VARCHAR(50),
    ended_at VARCHAR(50),
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(100),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(100),
    start_lat VARCHAR(50),
    start_lng VARCHAR(50),
    end_lat VARCHAR(50),
    end_lng VARCHAR(50),
    member_casual VARCHAR(50)
);