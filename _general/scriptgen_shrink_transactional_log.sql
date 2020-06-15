SELECT NAME
	,log_reuse_wait
	,log_reuse_wait_desc
	,*
FROM sys.databases
WHERE log_reuse_wait != 0
GO


SELECT 
      'USE [' + d.name + N']' + CHAR(13) + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE d.database_id > 4 and mf.type_desc = 'LOG' and log_reuse_wait =0