-- ============================================================
-- Index Management
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- Create a clustered index
-- (Each table can have only ONE clustered index)
-- -----------------------------------------------------------
-- Drop existing primary key clustered index first if replacing it
-- CREATE UNIQUE CLUSTERED INDEX CIX_Employees_EmployeeID ON Employees(EmployeeID);

-- -----------------------------------------------------------
-- Create a non-clustered index (single column)
-- -----------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName ASC);
GO

-- -----------------------------------------------------------
-- Create a composite (multi-column) index
-- -----------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Employees_DeptSalary
ON Employees (DepartmentID ASC, Salary DESC);
GO

-- -----------------------------------------------------------
-- Create a unique index
-- -----------------------------------------------------------
CREATE UNIQUE NONCLUSTERED INDEX UX_Employees_Email
ON Employees (Email)
WHERE Email IS NOT NULL;  -- filtered index: only index non-NULL emails
GO

-- -----------------------------------------------------------
-- Create an index with included (covering) columns
-- Included columns satisfy query without additional key lookups
-- -----------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Employees_HireDate_Covering
ON Employees (HireDate ASC)
INCLUDE (FirstName, LastName, Salary, DepartmentID);
GO

-- -----------------------------------------------------------
-- Create a filtered index (partial index)
-- Only indexes active employees — smaller and faster
-- -----------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Employees_Active_Salary
ON Employees (Salary DESC)
WHERE IsActive = 1;
GO

-- -----------------------------------------------------------
-- View indexes on a table
-- -----------------------------------------------------------
EXEC sp_helpindex 'Employees';
GO

-- Alternative: query sys catalog
SELECT
    i.name                      AS IndexName,
    i.type_desc                 AS IndexType,
    i.is_unique                 AS IsUnique,
    i.is_primary_key            AS IsPrimaryKey,
    i.filter_definition         AS FilterDefinition,
    STRING_AGG(c.name, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS IndexColumns
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Employees')
  AND ic.is_included_column = 0
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key, i.filter_definition
ORDER BY i.name;
GO

-- -----------------------------------------------------------
-- View index fragmentation
-- -----------------------------------------------------------
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name                     AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(
        DB_ID(),        -- current database
        NULL,           -- all tables
        NULL,           -- all indexes
        NULL,           -- all partitions
        'LIMITED'       -- LIMITED, SAMPLED, or DETAILED
    ) AS ips
INNER JOIN sys.indexes i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5  -- only fragmented indexes
  AND ips.page_count > 100                  -- ignore tiny indexes
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- -----------------------------------------------------------
-- Rebuild an index (removes all fragmentation, takes more time/locks)
-- -----------------------------------------------------------
ALTER INDEX IX_Employees_LastName ON Employees REBUILD;
GO

-- Rebuild with ONLINE option (SQL Server Enterprise/Developer only)
ALTER INDEX IX_Employees_LastName ON Employees
REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON, FILLFACTOR = 80);
GO

-- Rebuild ALL indexes on a table
ALTER INDEX ALL ON Employees REBUILD;
GO

-- -----------------------------------------------------------
-- Reorganize an index (online, less intrusive, for low fragmentation)
-- -----------------------------------------------------------
ALTER INDEX IX_Employees_LastName ON Employees REORGANIZE;
GO

-- -----------------------------------------------------------
-- Update index statistics
-- -----------------------------------------------------------
UPDATE STATISTICS Employees IX_Employees_LastName;
GO

-- Update all statistics on a table
UPDATE STATISTICS Employees;
GO

-- Update all statistics in the database
EXEC sp_updatestats;
GO

-- -----------------------------------------------------------
-- Disable and enable an index
-- -----------------------------------------------------------
ALTER INDEX IX_Employees_LastName ON Employees DISABLE;
GO
ALTER INDEX IX_Employees_LastName ON Employees REBUILD;  -- re-enables by rebuilding
GO

-- -----------------------------------------------------------
-- Find missing indexes suggested by query optimizer
-- (based on queries executed since last SQL Server restart)
-- -----------------------------------------------------------
SELECT TOP 20
    mid.statement                           AS TableName,
    migs.avg_total_user_cost * migs.avg_user_impact
        * (migs.user_seeks + migs.user_scans) AS ImprovementMeasure,
    mig.equality_columns,
    mig.inequality_columns,
    mig.included_columns,
    migs.unique_compiles,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats  AS migs
INNER JOIN sys.dm_db_missing_index_groups AS mig
    ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid
    ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY ImprovementMeasure DESC;
GO

-- -----------------------------------------------------------
-- Drop an index
-- -----------------------------------------------------------
DROP INDEX IF EXISTS IX_Employees_LastName ON Employees;
GO
