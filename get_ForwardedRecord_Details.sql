USE DBName

SELECT DB_NAME() DBName,
    OBJECT_NAME(ps.object_id) as TableName,
    i.name as IndexName,
    ps.index_type_desc,
    ps.page_count,
    ps.avg_fragmentation_in_percent,
    ps.forwarded_record_count
	,'USE '+DB_NAME()+'; ALTER TABLE '+OBJECT_NAME(ps.object_id)+' REBUILD;' Script
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ps
INNER JOIN sys.indexes AS i
    ON ps.OBJECT_ID = i.OBJECT_ID  
    AND ps.index_id = i.index_id
WHERE forwarded_record_count > 0


-------------------------------------------------------------------
--All DBs--
-------------------------------------------------------------------

DECLARE @command VARCHAR(1000)

SELECT @command = 'USE [?] 

SELECT DB_NAME() DBName,
    OBJECT_NAME(ps.object_id) as TableName,
    i.name as IndexName,
    ps.index_type_desc,
    ps.page_count,
    ps.avg_fragmentation_in_percent,
    ps.forwarded_record_count,
	''USE ''+DB_NAME()+''; ALTER TABLE ''+OBJECT_NAME(ps.object_id)+'' REBUILD;'' Script
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, ''DETAILED'') AS ps
INNER JOIN sys.indexes AS i
    ON ps.OBJECT_ID = i.OBJECT_ID  
    AND ps.index_id = i.index_id
WHERE forwarded_record_count > 0'

EXEC sp_MSforeachdb @command

