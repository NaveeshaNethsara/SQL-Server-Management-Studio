-- ============================================================
-- Database Operations
-- SQL Server Management Studio Query File
-- ============================================================

-- -----------------------------------------------------------
-- Create a new database
-- -----------------------------------------------------------
CREATE DATABASE MyDatabase;
GO

-- Create database with specific settings
CREATE DATABASE MyDatabase
ON PRIMARY
(
    NAME = 'MyDatabase_Data',
    FILENAME = 'C:\SQLData\MyDatabase.mdf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = 'MyDatabase_Log',
    FILENAME = 'C:\SQLData\MyDatabase_log.ldf',
    SIZE = 20MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 5MB
);
GO

-- -----------------------------------------------------------
-- Select a database to use
-- -----------------------------------------------------------
USE MyDatabase;
GO

-- -----------------------------------------------------------
-- View all databases
-- -----------------------------------------------------------
SELECT name, database_id, create_date, state_desc
FROM sys.databases
ORDER BY name;
GO

-- -----------------------------------------------------------
-- View database properties
-- -----------------------------------------------------------
SELECT
    name,
    recovery_model_desc,
    log_reuse_wait_desc,
    compatibility_level,
    collation_name,
    is_read_only,
    is_auto_close_on,
    is_auto_shrink_on
FROM sys.databases
WHERE name = 'MyDatabase';
GO

-- -----------------------------------------------------------
-- Change database recovery model
-- -----------------------------------------------------------
ALTER DATABASE MyDatabase SET RECOVERY FULL;
GO
ALTER DATABASE MyDatabase SET RECOVERY SIMPLE;
GO
ALTER DATABASE MyDatabase SET RECOVERY BULK_LOGGED;
GO

-- -----------------------------------------------------------
-- Change database compatibility level
-- -----------------------------------------------------------
-- SQL Server 2022 = 160
-- SQL Server 2019 = 150
-- SQL Server 2017 = 140
-- SQL Server 2016 = 130
ALTER DATABASE MyDatabase SET COMPATIBILITY_LEVEL = 160;
GO

-- -----------------------------------------------------------
-- Rename a database
-- -----------------------------------------------------------
ALTER DATABASE MyDatabase MODIFY NAME = MyRenamedDatabase;
GO

-- -----------------------------------------------------------
-- Set database to single user mode
-- -----------------------------------------------------------
ALTER DATABASE MyDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Set database back to multi user mode
ALTER DATABASE MyDatabase SET MULTI_USER;
GO

-- -----------------------------------------------------------
-- Take database offline / bring online
-- -----------------------------------------------------------
ALTER DATABASE MyDatabase SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE MyDatabase SET ONLINE;
GO

-- -----------------------------------------------------------
-- Drop a database
-- -----------------------------------------------------------
-- Make sure no one is connected before dropping
ALTER DATABASE MyDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE MyDatabase;
GO

-- -----------------------------------------------------------
-- Check database size
-- -----------------------------------------------------------
EXEC sp_helpdb 'MyDatabase';
GO

-- Alternative: get database file sizes
SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS LogicalName,
    physical_name AS PhysicalName,
    type_desc AS FileType,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS SizeMB,
    CASE max_size
        WHEN -1 THEN 'Unlimited'
        ELSE CAST(max_size * 8.0 / 1024 AS VARCHAR(20))
    END AS MaxSizeMB
FROM sys.master_files
WHERE database_id = DB_ID('MyDatabase');
GO
