/*
Script Name : Check_Statistics_Older_Than_30_Days.sql

Purpose:
Identify user table statistics that have not been updated in the last 30 days.

When to Use:
- Before post-migration validation
- Before performance testing
- During routine database health checks
- To identify stale statistics that may affect query performance

Risk Level:
Read Only

Recommended Action:
Review the output and update only the required statistics instead of performing a blanket update on all tables.

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Check_Statistics_Older_Than_30_Days.sql
*/

SELECT
    QUOTENAME(sch.name) + '.' + QUOTENAME(so.name) AS TableName,
    ss.name AS StatisticName,
    CASE
        WHEN ss.auto_created = 0 AND ss.user_created = 0 THEN 'Index Statistic'
        WHEN ss.auto_created = 0 AND ss.user_created = 1 THEN 'User Created'
        WHEN ss.auto_created = 1 AND ss.user_created = 0 THEN 'Auto Created'
        ELSE 'Other'
    END AS StatisticType,
    CASE
        WHEN ss.has_filter = 1 THEN 'Filtered'
        ELSE 'No Filter'
    END AS FilteredStatus,
    ISNULL(ss.filter_definition, '') AS FilterDefinition,
    sp.last_updated AS StatsLastUpdated,
    sp.rows AS [Rows],
    sp.rows_sampled AS RowsSampled,
    sp.unfiltered_rows AS UnfilteredRows,
    sp.modification_counter AS RowModifications,
    sp.steps AS HistogramSteps
FROM sys.stats ss
INNER JOIN sys.objects so
    ON ss.object_id = so.object_id
INNER JOIN sys.schemas sch
    ON so.schema_id = sch.schema_id
OUTER APPLY sys.dm_db_stats_properties(so.object_id, ss.stats_id) AS sp
WHERE so.type = 'U'
  AND sp.last_updated < DATEADD(DAY, -30, GETDATE())
ORDER BY sp.last_updated DESC;