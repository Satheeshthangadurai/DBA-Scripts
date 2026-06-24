/*
Script Name : Generate_Table_Level_Update_Statistics.sql
Purpose     : Generate table-level UPDATE STATISTICS commands for all user databases
Risk Level  : Low - Print Only
Usage       : Review generated commands before execution
*/

DECLARE @sql NVARCHAR(MAX) = N'';
DECLARE @stats NVARCHAR(MAX) = N'';

SELECT @sql += N'
EXEC ' + QUOTENAME(name) + N'.sys.sp_executesql @stats;'
FROM sys.databases 
WHERE database_id > 4
  AND state_desc = 'ONLINE'
  AND user_access_desc = 'MULTI_USER'
  AND is_read_only = 0;

SET @stats = N'
DECLARE @inner NVARCHAR(MAX) = N'''';

SELECT @inner += CHAR(10) + N''UPDATE STATISTICS ''
    + QUOTENAME(s.name) + ''.'' + QUOTENAME(t.name) + '';'' 
FROM sys.tables AS t
INNER JOIN sys.schemas AS s 
    ON t.schema_id = s.schema_id;

PRINT CHAR(10) + DB_NAME() + CHAR(10) + @inner;

-- Uncomment only after review
-- EXEC sys.sp_executesql @inner;
';

EXEC master.sys.sp_executesql 
    @sql, 
    N'@stats NVARCHAR(MAX)', 
    @stats;