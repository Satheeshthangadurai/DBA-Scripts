/*
Script Name : Reference_Update_Statistics_Syntax.sql
Purpose     : Basic syntax reference for updating SQL Server statistics
Risk Level  : Reference Only
*/

-- Update all statistics in current database
EXEC sp_updatestats;

-- Update statistics for one table
UPDATE STATISTICS [Schema_Name].[Table_Name];

-- Update one specific statistic/index on a table
UPDATE STATISTICS [Schema_Name].[Table_Name] [Statistic_or_Index_Name];