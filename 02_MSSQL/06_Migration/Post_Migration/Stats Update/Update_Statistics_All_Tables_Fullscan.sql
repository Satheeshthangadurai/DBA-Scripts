/*
Script Name : Update_Statistics_All_Tables_Fullscan.sql

Purpose:
Generate UPDATE STATISTICS commands with FULLSCAN for all user tables in the database.

When to Use:
- Post-migration performance validation
- Performance troubleshooting for critical workloads
- Before major business events or examination periods
- After significant data changes (bulk load, archive, purge activities)
- When inaccurate statistics are suspected to be causing poor query performance

Risk Level:
High

Usage:
- Execute only during a planned maintenance window.
- Review the generated commands before execution.
- Uncomment the EXEC statement only after validation.

Warning:
- FULLSCAN reads all rows in the table.
- May generate heavy CPU, IO, TempDB, and transaction log usage.
- Can increase blocking and affect application performance.
- Not recommended as a routine daily maintenance activity for large databases.

Recommended Action:
Use FULLSCAN only for specific critical tables or during post-migration activities. For routine maintenance, consider using EXEC sp_updatestats.

Output:
Generates UPDATE STATISTICS commands with FULLSCAN for all user tables.

Repository Location:
02_MSSQL\08_Maintenance\01_Update_Statistics\Update_Statistics_All_Tables_Fullscan.sql
*/

DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
(
    SELECT
        'UPDATE STATISTICS '
        + QUOTENAME(s.name) + '.'
        + QUOTENAME(o.name)
        + ' WITH FULLSCAN;'
        + CHAR(13) + CHAR(10)
    FROM sys.objects o
    INNER JOIN sys.schemas s
        ON o.schema_id = s.schema_id
    WHERE o.type = 'U'
    ORDER BY o.name
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)');

PRINT @sql;

-- Review the generated commands first
-- EXEC sys.sp_executesql @sql;