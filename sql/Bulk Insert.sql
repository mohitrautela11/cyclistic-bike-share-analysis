DECLARE @files TABLE (filename VARCHAR(100));
INSERT INTO @files VALUES 
('202511-divvy-tripdata.csv'),
('202512-divvy-tripdata.csv'),
('202601-divvy-tripdata.csv'),
('202602-divvy-tripdata.csv'),
('202603-divvy-tripdata.csv'),
('202604-divvy-tripdata.csv'),
('202605-divvy-tripdata.csv'),
('202606-divvy-tripdata.csv'),
('202607-divvy-tripdata.csv'),
('202608-divvy-tripdata.csv'),
('202609-divvy-tripdata.csv'),
('202610-divvy-tripdata.csv');

DECLARE @file VARCHAR(100), @sql NVARCHAR(MAX);

DECLARE file_cursor CURSOR FOR SELECT filename FROM @files;
OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @file;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = '
    BULK INSERT dbo.trips_raw
    FROM ''F:\BA\Projects\Cyclistic\Raw_CSV\' + @file + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''0x0a'',
        TABLOCK
    );';
    EXEC sp_executesql @sql;
    PRINT 'Loaded: ' + @file;
    FETCH NEXT FROM file_cursor INTO @file;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;