/*
Script Name : Check_All_Statistics_Last_Updated.sql

Purpose:
Show the last updated date and auto-update setting for all user table statistics.

When to Use:
- General statistics health check
- Before updating statistics
- After migration
- Before performance testing
- To check whether auto-update statistics is disabled

Risk Level:
Read Only

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Check_All_Statistics_Last_Updated.sql
*/

SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,
    OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticName,
    STATS_DATE(s.object_id, s.stats_id) AS StatsLastUpdated,
    s.auto_created AS AutoCreated,
    s.user_created AS UserCreated,
    s.no_recompute AS AutoUpdateStatsDisabled
FROM sys.stats s
INNER JOIN sys.objects o
    ON s.object_id = o.object_id
WHERE o.type = 'U'
ORDER BY StatsLastUpdated ASC;