-- ============================================================
-- Query Performance Monitoring and Tuning
-- SQL Server Management Studio Query File
-- ============================================================

USE master;
GO

-- -----------------------------------------------------------
-- Currently running queries
-- -----------------------------------------------------------
SELECT
    r.session_id,
    r.status,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time / 1000.0          AS WaitTimeSec,
    r.total_elapsed_time / 1000.0 AS ElapsedTimeSec,
    r.cpu_time / 1000.0           AS CpuTimeSec,
    r.reads,
    r.writes,
    r.logical_reads,
    DB_NAME(r.database_id)        AS DatabaseName,
    s.login_name,
    s.host_name,
    s.program_name,
    t.text                        AS QueryText
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
WHERE r.session_id <> @@SPID  -- exclude current session
ORDER BY r.total_elapsed_time DESC;
GO

-- -----------------------------------------------------------
-- Top 20 most expensive queries by CPU
-- -----------------------------------------------------------
SELECT TOP 20
    qs.total_worker_time / qs.execution_count AS AvgCpuUs,
    qs.total_worker_time                      AS TotalCpuUs,
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS AvgElapsedUs,
    qs.total_logical_reads / qs.execution_count AS AvgLogicalReads,
    qs.creation_time,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
              WHEN -1 THEN DATALENGTH(qt.text)
              ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1) AS QueryText,
    DB_NAME(qt.dbid) AS DatabaseName
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_worker_time DESC;
GO

-- -----------------------------------------------------------
-- Top 20 most expensive queries by logical reads (I/O)
-- -----------------------------------------------------------
SELECT TOP 20
    qs.total_logical_reads / qs.execution_count AS AvgLogicalReads,
    qs.total_logical_reads,
    qs.execution_count,
    qs.total_worker_time / qs.execution_count   AS AvgCpuUs,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
              WHEN -1 THEN DATALENGTH(qt.text)
              ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_logical_reads DESC;
GO

-- -----------------------------------------------------------
-- Blocking queries
-- -----------------------------------------------------------
SELECT
    blocking.session_id       AS BlockingSessionID,
    blocking_text.text        AS BlockingQuery,
    blocked.session_id        AS BlockedSessionID,
    blocked.wait_type,
    blocked.wait_time / 1000.0 AS WaitTimeSec,
    blocked_text.text         AS BlockedQuery,
    s.login_name,
    s.host_name
FROM sys.dm_exec_requests blocked
CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) blocked_text
INNER JOIN sys.dm_exec_requests blocking
    ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocking.sql_handle) blocking_text
INNER JOIN sys.dm_exec_sessions s ON blocked.session_id = s.session_id
WHERE blocked.blocking_session_id > 0;
GO

-- -----------------------------------------------------------
-- Active transactions
-- -----------------------------------------------------------
SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    t.transaction_begin_time,
    DATEDIFF(SECOND, t.transaction_begin_time, GETDATE()) AS OpenSeconds,
    t.transaction_type,
    t.transaction_state,
    dt.database_transaction_log_bytes_used / 1024.0       AS LogKBUsed,
    r_text.text                                           AS CurrentQuery
FROM sys.dm_tran_session_transactions st
INNER JOIN sys.dm_exec_sessions s       ON st.session_id = s.session_id
INNER JOIN sys.dm_tran_active_transactions t ON st.transaction_id = t.transaction_id
INNER JOIN sys.dm_tran_database_transactions dt ON st.transaction_id = dt.transaction_id
LEFT  JOIN sys.dm_exec_requests r       ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) r_text
WHERE t.transaction_type <> 2  -- exclude system transactions
ORDER BY t.transaction_begin_time;
GO

-- -----------------------------------------------------------
-- Wait statistics (server-wide bottlenecks since last restart)
-- -----------------------------------------------------------
SELECT TOP 20
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0                       AS WaitTimeSec,
    max_wait_time_ms / 1000.0                   AS MaxWaitTimeSec,
    (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceWaitSec,
    signal_wait_time_ms / 1000.0                AS SignalWaitSec,
    CAST(100.0 * wait_time_ms / SUM(wait_time_ms) OVER () AS DECIMAL(5,2)) AS PctTotal
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    -- Filter out benign waits
    'SLEEP_TASK','SLEEP_SYSTEMTASK','SLEEP_DBSTARTUP','SLEEP_DBTASK',
    'SLEEP_TEMPDBSTARTUP','SNI_HTTP_ACCEPT','DISPATCHER_QUEUE_SEMAPHORE',
    'XE_DISPATCHER_WAIT','XE_TIMER_EVENT','WAITFOR','LAZYWRITER_SLEEP',
    'CHECKPOINT_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH','RESOURCE_QUEUE',
    'SERVER_IDLE_CHECK','HADR_WORK_QUEUE','HADR_FILESTREAM_IOMGR_IOCOMPLETION',
    'BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_AUTO_EVENT','CLR_MANUAL_EVENT',
    'DISPATCHER_QUEUE_SEMAPHORE','FT_IFTS_SCHEDULER_IDLE_WAIT',
    'SQLTRACE_BUFFER_FLUSH','WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
    'BROKER_EVENTHANDLER','ONDEMAND_TASK_QUEUE','WAIT_XTP_HOST_WAIT',
    'DBMIRROR_EVENTS_QUEUE','SQLTRACE_INCREMENTAL_FLUSH_SLEEP'
)
ORDER BY wait_time_ms DESC;
GO

-- -----------------------------------------------------------
-- Index usage statistics
-- -----------------------------------------------------------
USE MyDatabase;
GO

SELECT
    OBJECT_NAME(i.object_id)    AS TableName,
    i.name                      AS IndexName,
    i.type_desc                 AS IndexType,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_update
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE OBJECT_NAME(i.object_id) IS NOT NULL
ORDER BY OBJECT_NAME(i.object_id), i.name;
GO

-- -----------------------------------------------------------
-- Find unused indexes (candidates for removal)
-- -----------------------------------------------------------
SELECT
    OBJECT_NAME(i.object_id)    AS TableName,
    i.name                      AS IndexName,
    ISNULL(ius.user_seeks, 0)   AS UserSeeks,
    ISNULL(ius.user_scans, 0)   AS UserScans,
    ISNULL(ius.user_lookups, 0) AS UserLookups,
    ISNULL(ius.user_updates, 0) AS UserUpdates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id  = ius.object_id
    AND i.index_id  = ius.index_id
    AND ius.database_id = DB_ID()
WHERE i.type_desc <> 'HEAP'
  AND i.is_primary_key  = 0
  AND i.is_unique       = 0
  AND ISNULL(ius.user_seeks, 0)   = 0
  AND ISNULL(ius.user_scans, 0)   = 0
  AND ISNULL(ius.user_lookups, 0) = 0
ORDER BY ISNULL(ius.user_updates, 0) DESC;
GO

-- -----------------------------------------------------------
-- Check SQL Server memory usage
-- -----------------------------------------------------------
USE master;
GO

SELECT
    physical_memory_in_use_kb / 1024.0    AS MemoryUsedMB,
    page_fault_count,
    memory_utilization_percentage
FROM sys.dm_os_process_memory;
GO

-- Buffer pool usage by database
SELECT
    DB_NAME(database_id)               AS DatabaseName,
    COUNT(*) * 8 / 1024.0              AS BufferPoolMB
FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767  -- exclude resource DB
GROUP BY database_id
ORDER BY COUNT(*) DESC;
GO
