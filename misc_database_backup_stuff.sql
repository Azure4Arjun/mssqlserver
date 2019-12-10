----- No backup in the last 24 Hours
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER
	,msdb.dbo.backupset.database_name
	,MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date
	,DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS [Backup Age (Hours)]
FROM msdb.dbo.backupset
WHERE msdb.dbo.backupset.type = 'D'
GROUP BY msdb.dbo.backupset.database_name
HAVING (MAX(msdb.dbo.backupset.backup_finish_date) < DATEADD(hh, - 48, GETDATE()))

UNION

--Databases without any backup history 
SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER
	,master.dbo.sysdatabases.NAME AS database_name
	,NULL AS [Last Data Backup Date]
	,9999 AS [Backup Age (Hours)]
FROM master.dbo.sysdatabases
LEFT JOIN msdb.dbo.backupset
	ON master.dbo.sysdatabases.name = msdb.dbo.backupset.database_name
LEFT JOIN sys.databases s on s.name=master.dbo.sysdatabases.name 
WHERE msdb.dbo.backupset.database_name IS NULL
	AND master.dbo.sysdatabases.name <> 'tempdb'
AND state_desc !='OFFLINE'
ORDER BY msdb.dbo.backupset.database_name
----------------------------
			      
WITH D1
AS (
	SELECT database_name
		,backupset.type
		,max(backup_finish_date) Last_backup_finish_date
	FROM msdb.dbo.backupset
	GROUP BY database_name
		,backupset.type
	)
SELECT server_name
	,bs.database_name
	,CASE 
		WHEN bs.type = 'D'
			THEN 'FULL'
		WHEN bs.type = 'I'
			THEN 'DIFF'
		WHEN bs.type = 'L'
			THEN 'LOG'
		END type
	,user_name
	,backup_start_date
	,backup_finish_date
	,DATEDIFF(minute,backup_start_date,backup_finish_date) Min_Backup_Time
	,DATEDIFF(minute,backup_finish_date,GETDATE()) Min_Since_Last_Backup
	,recovery_model
FROM D1
LEFT JOIN msdb.dbo.backupset bs ON d1.database_name = bs.database_name
	AND d1.type = bs.type
	AND d1.Last_backup_finish_date = bs.backup_finish_date
ORDER BY db_id(d1.database_name)
	,d1.type

			      
			
----------------------------

WITH Date_Range_1
AS (
	SELECT DATEADD(day, number - 1, CAST(GETDATE() - 4 AS DATE)) AS [DateR]
	FROM (
		SELECT ROW_NUMBER() OVER (
				ORDER BY n.object_id
				)
		FROM sys.all_objects n
		) S(number)
	WHERE number <= DATEDIFF(day, CAST(GETDATE() - 4 AS DATE), CAST(GETDATE() AS DATE)) --+ 1
	)
	,Date_Range
AS (
	SELECT DateR
		,name
		,state_desc
		,is_in_standby
		,is_read_only
	FROM sys.databases
	JOIN Date_Range_1 ON 1 = 1
	WHERE state_desc = 'Online'
	)
	,Backup_SET
AS (
	SELECT database_name
		,CAST(backup_start_date AS DATE) backup_start_date
		,cast(backup_finish_date AS DATE) backup_finish_date
	FROM msdb..backupset
	WHERE type = 'D'
		AND backup_start_date > getdate() - 4
		--AND database_name = 'SP_UAT_CRM_0'
	)
SELECT D.*
	,B.*
FROM Date_Range D 
LEFT JOIN Backup_SET B ON D.DateR=B.backup_start_date and D.name=B.database_name
where database_name is null and name !='tempdb'
ORDER BY D.DateR,D.name
-----------------------------------------------------------------------
				 
				 WITH D
AS (
	SELECT a.server_name
		,a.database_name
		,a.user_name
		,CASE a.[type]
			WHEN 'D'
				THEN 'Full'
			WHEN 'I'
				THEN 'Diff'
			WHEN 'L'
				THEN 'Log'
			ELSE a.[type]
			END AS BackupType
		,max(a.media_set_id) media_set_id
		,max(backup_finish_date) backup_finish_date
	FROM msdb.dbo.backupset a
	WHERE user_name = (
			SELECT service_account
			FROM sys.dm_server_services
			WHERE servicename LIKE '%Agent%'
			)
	GROUP BY a.server_name
		,a.database_name
		,a.user_name
		,CASE a.[type]
			WHEN 'D'
				THEN 'Full'
			WHEN 'I'
				THEN 'Diff'
			WHEN 'L'
				THEN 'Log'
			ELSE a.[type]
			END
	)
	,D1
AS (
	SELECT D.*
		,Datediff(hour, backup_finish_date, getdate()) hr_since_kp
		,b.physical_device_name
	FROM D
	JOIN msdb.dbo.backupmediafamily b ON d.media_set_id = b.media_set_id
	)
SELECT S.name
	,D1.*
FROM sys.databases s
LEFT JOIN D1 ON s.name = d1.database_name
WHERE s.name != 'tempdb'
	AND backup_finish_date > getdate() - 90
ORDER BY server_name
	,database_name
	,user_name
	,BackupType;
