/*
Script Name : Check_Index_Statistics_Last_Updated.sql

Purpose:
Check when index statistics were last updated and verify whether
automatic statistics updates are enabled or disabled.

Risk Level:
Read Only
*/

SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,
    OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticName,
    CASE s.no_recompute
        WHEN 1 THEN 'OFF'
        ELSE 'ON'
    END AS AutoStats,
    s.auto_created AS AutoCreated,
    STATS_DATE(s.object_id, s.stats_id) AS LastUpdated
FROM sys.stats s
WHERE OBJECTPROPERTY(s.object_id, 'IsSystemTable') = 0
  AND OBJECT_NAME(s.object_id) NOT LIKE 'ifts%'
  AND OBJECT_NAME(s.object_id) NOT LIKE 'fulltext%'
  AND s.auto_created = 0
ORDER BY LastUpdated DESC;