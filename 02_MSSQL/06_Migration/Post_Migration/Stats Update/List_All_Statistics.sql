/*
Script Name : List_All_Statistics.sql
Purpose     : List all statistics for user tables
When to Use : Baseline check before/after migration or maintenance
Risk Level  : Read Only
*/

SELECT
    QUOTENAME(sch.name) + '.' + QUOTENAME(so.name) AS TableName,
    so.object_id,
    ss.name AS StatisticName,
    ss.stats_id,
    CASE
        WHEN ss.auto_created = 1 THEN 'Auto Created'
        WHEN ss.user_created = 1 THEN 'User Created'
        ELSE 'Index Statistic'
    END AS StatisticType,
    STATS_DATE(ss.object_id, ss.stats_id) AS StatsLastUpdated
FROM sys.stats ss
INNER JOIN sys.objects so
    ON ss.object_id = so.object_id
INNER JOIN sys.schemas sch
    ON so.schema_id = sch.schema_id
WHERE so.type = 'U'
ORDER BY TableName, StatisticName;