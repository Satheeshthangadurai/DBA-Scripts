/*
Script Name : Check_Detailed_Statistics_Info.sql

Purpose:
Show detailed statistics information for user tables, including statistic type,
columns involved, filter definition, last updated date, rows sampled,
histogram steps, and row modification count.

When to Use:
- Deep statistics investigation
- Performance troubleshooting
- Post-migration validation
- Before deciding whether to run UPDATE STATISTICS
- To review filtered, auto-created, user-created, and index statistics

Risk Level:
Read Only

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Check_Detailed_Statistics_Info.sql
*/

USE [databasename]; -- replace database name
GO

IF OBJECT_ID('tempdb..#StatsInfo') IS NOT NULL
    DROP TABLE #StatsInfo;

IF OBJECT_ID('tempdb..#ColumnList') IS NOT NULL
    DROP TABLE #ColumnList;

DECLARE @object_id INT = NULL;

-- For one table only, uncomment and change table name:
-- SET @object_id = OBJECT_ID(N'Sales.Invoices');

SELECT
    ss.name AS SchemaName,
    obj.name AS TableName,
    stat.stats_id,
    stat.name AS StatisticsName,
    CASE
        WHEN stat.auto_created = 0 AND stat.user_created = 0 THEN 'Index Statistic'
        WHEN stat.auto_created = 0 AND stat.user_created = 1 THEN 'User Created'
        WHEN stat.auto_created = 1 AND stat.user_created = 0 THEN 'Auto Created'
        ELSE 'Other'
    END AS StatisticType,
    CASE
        WHEN stat.is_temporary = 0 THEN 'Stats in DB'
        WHEN stat.is_temporary = 1 THEN 'Stats in TempDB'
    END AS IsTemporary,
    CASE
        WHEN stat.has_filter = 1 THEN 'Filtered'
        ELSE 'No Filter'
    END AS IsFiltered,
    c.name AS ColumnName,
    stat.filter_definition,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.steps AS HistogramSteps,
    sp.unfiltered_rows,
    sp.modification_counter AS RowsModified
INTO #StatsInfo
FROM sys.objects AS obj
INNER JOIN sys.schemas ss
    ON obj.schema_id = ss.schema_id
INNER JOIN sys.stats stat
    ON stat.object_id = obj.object_id
INNER JOIN sys.stats_columns sc
    ON sc.object_id = stat.object_id
    AND sc.stats_id = stat.stats_id
INNER JOIN sys.columns c
    ON c.object_id = sc.object_id
    AND c.column_id = sc.column_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE obj.is_ms_shipped = 0
  AND obj.type = 'U'
  AND (@object_id IS NULL OR obj.object_id = @object_id);

SELECT
    t.SchemaName,
    t.TableName,
    t.stats_id,
    STUFF
    (
        (
            SELECT ',' + s.ColumnName
            FROM #StatsInfo s
            WHERE s.SchemaName = t.SchemaName
              AND s.TableName = t.TableName
              AND s.stats_id = t.stats_id
            FOR XML PATH('')
        ), 1, 1, ''
    ) AS ColumnList
INTO #ColumnList
FROM #StatsInfo AS t
GROUP BY
    t.SchemaName,
    t.TableName,
    t.stats_id;

SELECT DISTINCT
    SI.SchemaName,
    SI.TableName,
    SI.stats_id,
    SI.StatisticsName,
    SI.StatisticType,
    SI.IsTemporary,
    CL.ColumnList AS ColumnName,
    SI.IsFiltered,
    SI.filter_definition,
    SI.last_updated,
    SI.rows,
    SI.rows_sampled,
    SI.HistogramSteps,
    SI.unfiltered_rows,
    SI.RowsModified
FROM #StatsInfo SI
INNER JOIN #ColumnList CL
    ON SI.SchemaName = CL.SchemaName
    AND SI.TableName = CL.TableName
    AND SI.stats_id = CL.stats_id
ORDER BY
    SI.SchemaName,
    SI.TableName,
    SI.StatisticsName;