/*
Script Name : Check_Statistics_Modification_Counter.sql
Purpose     : Check statistics last updated date, rows sampled, and row modification count
Risk Level  : Read Only
Usage       : Run before UPDATE STATISTICS / sp_updatestats
*/

SELECT
    QUOTENAME(SCH.name) + '.' + QUOTENAME(SO.name) AS TableName,
    SS.name AS StatisticName,
    SP.last_updated AS StatsLastUpdated,
    SP.rows AS RowsInTable,
    SP.rows_sampled AS RowsSampled,
    SP.modification_counter AS RowModifications
FROM sys.stats SS
INNER JOIN sys.objects SO
    ON SS.object_id = SO.object_id
INNER JOIN sys.schemas SCH
    ON SO.schema_id = SCH.schema_id
OUTER APPLY sys.dm_db_stats_properties(SO.object_id, SS.stats_id) SP
WHERE SO.type = 'U'
  AND ISNULL(SP.modification_counter, 0) > 0
ORDER BY SP.modification_counter DESC;