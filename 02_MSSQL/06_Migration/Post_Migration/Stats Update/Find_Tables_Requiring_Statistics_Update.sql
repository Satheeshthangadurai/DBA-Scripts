/*
Script Name : Find_Tables_Requiring_Statistics_Update.sql

Purpose:
Identify tables and statistics where row modifications exceed 1% of the total table rows.

When to Use:
- Before running UPDATE STATISTICS
- During routine database health checks
- Before performance testing activities
- After large data loads, bulk inserts, updates, or deletes
- Post-migration validation and performance tuning activities

Risk Level:
Read Only

Recommended Action:
Review the output and update statistics only for the identified tables instead of updating statistics for the entire database.

Output Information:
- Schema Name
- Table Name
- Statistic Name
- Statistics Last Updated Date
- Total Rows in Table
- Number of Modified Rows
- Percentage of Data Changes

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Find_Tables_Requiring_Statistics_Update.sql
*/

SELECT
    sch.name AS SchemaName,
    so.name AS TableName,
    ss.name AS StatisticName,
    sp.last_updated AS StatsLastUpdated,
    sp.rows AS TotalRows,
    sp.modification_counter AS ModifiedRows,
    CAST(
        CAST(sp.modification_counter AS DECIMAL(18,2))
        / NULLIF(sp.rows,0) * 100
        AS DECIMAL(10,2)
    ) AS ModificationPercent
FROM sys.stats ss
INNER JOIN sys.objects so
    ON ss.object_id = so.object_id
INNER JOIN sys.schemas sch
    ON so.schema_id = sch.schema_id
CROSS APPLY sys.dm_db_stats_properties(so.object_id, ss.stats_id) sp
WHERE so.type = 'U'
  AND ss.user_created = 0
  AND sp.modification_counter > 0
  AND (CAST(sp.modification_counter AS DECIMAL(18,2))
       / NULLIF(sp.rows,0)) > 0.01
ORDER BY sp.last_updated DESC;