/*
Script Name : PostMigration_Update_Statistics_All_User_Databases.sql
Purpose     : Update statistics for all online user databases after migration
Risk Level  : Medium
Run Window  : Maintenance window recommended
Notes       : Review generated commands first before execution
*/

DECLARE @SQL NVARCHAR(MAX) = N'';

SELECT @SQL += N'
PRINT ''Updating statistics for database: ' + QUOTENAME(name) + N''';
EXEC ' + QUOTENAME(name) + N'.sys.sp_updatestats;
'
FROM sys.databases
WHERE database_id > 4
  AND state_desc = 'ONLINE'
  AND user_access_desc = 'MULTI_USER'
  AND is_read_only = 0
ORDER BY name;

PRINT @SQL;

-- After review, uncomment below line to execute
-- EXEC sys.sp_executesql @SQL;