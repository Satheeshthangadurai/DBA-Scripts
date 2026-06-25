/*
Script Name : Check_Auto_Update_Statistics_Disabled.sql

Purpose:
Identify user table statistics where automatic statistics updates (AUTO_UPDATE_STATISTICS) have been disabled using the NORECOMPUTE option.

When to Use:
- During database health checks
- After migration activities
- During performance troubleshooting
- To identify manually managed statistics
- Before enabling automatic statistics maintenance
- To verify statistics maintenance configuration

Risk Level:
Read Only

Recommended Action:
Review the output carefully. Statistics with NORECOMPUTE enabled will not be automatically updated by SQL Server and may require manual maintenance.

Output Information:
- Schema Name
- Table Name
- Statistic Name
- Statistics Last Updated Date
- Auto-Created Statistics Flag
- User-Created Statistics Flag
- Auto Update Statistics Disabled Status

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Check_Auto_Update_Statistics_Disabled.sql
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
  AND s.no_recompute = 1
ORDER BY StatsLastUpdated ASC;