/*
Script Name : Code_Generation_Scripts.sql

Purpose:
Generate commonly used SQL commands dynamically for administration,
validation, and maintenance activities.

When to Use:
- During migration validation
- During troubleshooting activities
- For quick administrative tasks
- Before maintenance activities
- To generate repetitive SQL commands automatically

Risk Level:
Read Only (Generation Only)

Available Utilities:
1. Generate SELECT statements for all user tables.
2. Generate UPDATE STATISTICS commands for all user tables.
3. Generate row count validation commands for migration verification.
4. Identify outdated statistics requiring attention.

Repository Location:
02_MSSQL\10_Utilities\Code_Generation_Scripts.sql
*/

------------------------------------------------------------
-- Generate SELECT statements for all user tables
------------------------------------------------------------
SELECT
    'SELECT * FROM '
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.'
    + QUOTENAME(name)
    + ';'
FROM sys.tables
ORDER BY name;


------------------------------------------------------------
-- Generate UPDATE STATISTICS commands
------------------------------------------------------------
SELECT
    'UPDATE STATISTICS '
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.'
    + QUOTENAME(name)
    + '; SELECT GETDATE();'
FROM sys.tables
ORDER BY name;


------------------------------------------------------------
-- Generate row count verification commands
-- Useful for migration validation
------------------------------------------------------------
SELECT
    'SELECT COUNT(*) AS [RowCount], '''
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.'
    + QUOTENAME(name)
    + ''' AS [TableName] FROM '
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.'
    + QUOTENAME(name)
    + ';'
FROM sys.tables
ORDER BY name;


------------------------------------------------------------
-- Check outdated statistics
-- Displays statistics not updated for more than 1 day
------------------------------------------------------------
SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,
    OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticName,
    STATS_DATE(s.object_id, s.stats_id) AS StatsLastUpdated,
    sp.modification_counter AS RowModifications
FROM sys.stats s
OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id IN (SELECT object_id FROM sys.tables)
  AND STATS_DATE(s.object_id, s.stats_id) <= DATEADD(DAY, -1, GETDATE())
  AND ISNULL(sp.modification_counter, 0) > 0
ORDER BY StatsLastUpdated;