-- ============================================================
-- Database Maintenance
-- SQL Server Management Studio Query File
-- ============================================================

USE master;
GO

-- -----------------------------------------------------------
-- Backup: Full database backup
-- -----------------------------------------------------------
BACKUP DATABASE MyDatabase
TO DISK = 'C:\SQLBackup\MyDatabase_Full.bak'
WITH FORMAT,           -- overwrite existing backup sets in the file
     INIT,             -- overwrite the media
     NAME = 'MyDatabase Full Backup',
     STATS = 10,       -- show progress every 10%
     COMPRESSION;      -- compress the backup
GO

-- -----------------------------------------------------------
-- Backup: Differential backup (changes since last full backup)
-- -----------------------------------------------------------
BACKUP DATABASE MyDatabase
TO DISK = 'C:\SQLBackup\MyDatabase_Diff.bak'
WITH DIFFERENTIAL,
     FORMAT,
     NAME = 'MyDatabase Differential Backup',
     STATS = 10,
     COMPRESSION;
GO

-- -----------------------------------------------------------
-- Backup: Transaction log backup (FULL or BULK_LOGGED recovery)
-- -----------------------------------------------------------
BACKUP LOG MyDatabase
TO DISK = 'C:\SQLBackup\MyDatabase_Log.bak'
WITH FORMAT,
     NAME = 'MyDatabase Log Backup',
     STATS = 10,
     COMPRESSION;
GO

-- -----------------------------------------------------------
-- Restore: Restore full backup (database must not be in use)
-- -----------------------------------------------------------
ALTER DATABASE MyDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE MyDatabase
FROM DISK = 'C:\SQLBackup\MyDatabase_Full.bak'
WITH REPLACE,           -- overwrite existing database
     NORECOVERY,        -- leave DB in restoring state for additional backups
     STATS = 10;
GO

-- -----------------------------------------------------------
-- Restore: Apply differential backup
-- -----------------------------------------------------------
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\SQLBackup\MyDatabase_Diff.bak'
WITH NORECOVERY,
     STATS = 10;
GO

-- -----------------------------------------------------------
-- Restore: Apply log backup
-- -----------------------------------------------------------
RESTORE LOG MyDatabase
FROM DISK = 'C:\SQLBackup\MyDatabase_Log.bak'
WITH NORECOVERY,
     STATS = 10;
GO

-- -----------------------------------------------------------
-- Restore: Bring database online (after applying all backups)
-- -----------------------------------------------------------
RESTORE DATABASE MyDatabase WITH RECOVERY;
GO

ALTER DATABASE MyDatabase SET MULTI_USER;
GO

-- -----------------------------------------------------------
-- Check backup history
-- -----------------------------------------------------------
SELECT TOP 20
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    DATEDIFF(MINUTE, bs.backup_start_date, bs.backup_finish_date) AS DurationMin,
    CAST(bs.backup_size / 1048576.0 AS DECIMAL(10,2))             AS BackupSizeMB,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        ELSE bs.type
    END AS BackupType,
    bmf.physical_device_name AS BackupFile
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
ORDER BY bs.backup_start_date DESC;
GO

-- -----------------------------------------------------------
-- DBCC: Check database integrity
-- -----------------------------------------------------------
USE MyDatabase;
GO

-- Full integrity check (may take a long time on large databases)
DBCC CHECKDB ('MyDatabase') WITH NO_INFOMSGS;
GO

-- Quick check (less thorough but faster)
DBCC CHECKDB ('MyDatabase') WITH PHYSICAL_ONLY, NO_INFOMSGS;
GO

-- Check a single table
DBCC CHECKTABLE ('Employees') WITH NO_INFOMSGS;
GO

-- -----------------------------------------------------------
-- Shrink database files (use sparingly — causes fragmentation)
-- -----------------------------------------------------------
-- Shrink log file
DBCC SHRINKFILE (MyDatabase_Log, 10);   -- shrink to 10 MB
GO

-- Shrink data file
DBCC SHRINKFILE (MyDatabase_Data, 100); -- shrink to 100 MB
GO

-- -----------------------------------------------------------
-- Rebuild all indexes in the database (maintenance)
-- -----------------------------------------------------------
USE MyDatabase;
GO

-- Dynamic SQL to rebuild all indexes
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'ALTER INDEX ALL ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(object_id))
             + '.' + QUOTENAME(OBJECT_NAME(object_id)) + ' REBUILD;' + CHAR(13)
FROM sys.tables
WHERE type = 'U';

EXEC sp_executesql @sql;
GO

-- -----------------------------------------------------------
-- Update all statistics in the database
-- -----------------------------------------------------------
EXEC sp_updatestats;
GO

-- Full statistics update using dynamic SQL (more thorough, more time-consuming)
DECLARE @statSql NVARCHAR(MAX) = '';

SELECT @statSql += 'UPDATE STATISTICS '
    + QUOTENAME(OBJECT_SCHEMA_NAME(object_id))
    + '.' + QUOTENAME(OBJECT_NAME(object_id))
    + ' WITH FULLSCAN;' + CHAR(13)
FROM sys.tables
WHERE type = 'U';

EXEC sp_executesql @statSql;
GO

-- -----------------------------------------------------------
-- Kill all connections to a database
-- -----------------------------------------------------------
USE master;
GO

DECLARE @KillSQL  NVARCHAR(MAX) = '';
DECLARE @SPID     SMALLINT;

SELECT @KillSQL += 'KILL ' + CAST(spid AS VARCHAR(5)) + '; '
FROM sys.sysprocesses
WHERE dbid = DB_ID('MyDatabase')
  AND spid <> @@SPID;  -- don't kill current session

IF LEN(@KillSQL) > 0
    EXEC sp_executesql @KillSQL;
GO

-- -----------------------------------------------------------
-- Check SQL Server error log
-- -----------------------------------------------------------
EXEC sp_readerrorlog 0, 1;   -- 0 = current log, 1 = SQL Server log
GO

-- -----------------------------------------------------------
-- Check SQL Server Agent job history
-- -----------------------------------------------------------
SELECT TOP 50
    j.name          AS JobName,
    jh.run_date,
    jh.run_time,
    jh.run_duration,
    CASE jh.run_status
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Cancelled'
        WHEN 4 THEN 'In Progress'
    END             AS RunStatus,
    jh.message
FROM msdb.dbo.sysjobhistory jh
INNER JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id
ORDER BY jh.run_date DESC, jh.run_time DESC;
GO
