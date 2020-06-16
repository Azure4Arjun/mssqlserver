DECLARE @target_p FLOAT = 15;-- Change %
DECLARE @p1 FLOAT;
DECLARE @p2 FLOAT;

SET @p1 = @target_p / 100;
SET @p2 = 1 - (@target_p / 100);

WITH D
AS (
	SELECT DISTINCT @@SERVERNAME ServerName
		,DB_NAME(dovs.database_id) DBName
		,mf.physical_name PhysicalFileLocation
		,mf.size * 8 / 1024 / 1024 size_GB
		,type_desc
		,dovs.logical_volume_name AS LogicalName
		,dovs.volume_mount_point AS Drive
		,(CONVERT(INT, dovs.total_bytes / 1048576.0) / 1024) AS Drive_Size_InGB
		,(CONVERT(INT, dovs.available_bytes / 1048576.0) / 1024) AS Drive_Free_Space_Available_InGB
		,CAST((CONVERT(FLOAT, dovs.available_bytes / 1048576.0) / 1024) / (CONVERT(FLOAT, dovs.total_bytes / 1048576.0) / 1024) * 100 AS DECIMAL(10, 2)) AS [%_Free]
		,cast(((((CONVERT(INT, dovs.total_bytes / 1048576.0) / 1024) * @p1) - (CONVERT(INT, dovs.available_bytes / 1048576.0) / 1024)) / @p2) AS DECIMAL(10, 2)) [target_%_add_gb]
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
	WHERE DB_NAME(dovs.database_id) NOT IN (
			'master'
			,'model'
			,'msdb'
			,'tempdb'
			)
		--AND type_desc = 'Rows'
		--AND dovs.volume_mount_point=''
	)
SELECT *
	,Drive_Free_Space_Available_InGB + [target_%_add_gb] Total_Target_gb
FROM D
ORDER BY Drive_Free_Space_Available_InGB ASC
GO
