IF OBJECT_ID('#Temp1') IS NOT NULL
	DROP TABLE #Temp1;

IF OBJECT_ID('#Temp2') IS NOT NULL
	DROP TABLE #Temp2;

CREATE TABLE #Temp1 (
	[database_name] [nvarchar](128) NULL
	,[LastFullBackup] [datetime] NULL
	,[LastDifferential] [datetime] NULL
	,[LastLog] [datetime] NULL
	,[hr_since_full] [int] NULL
	,[hr_since_diff] [int] NULL
	,[min_since_log] [int] NULL
	);

CREATE TABLE #Temp2 (
	[AG] [nvarchar](60) NULL
	,[name] [sysname] NULL
	,[backup_state] [varchar](2) NOT NULL
	,[LastFullBackup] [datetime] NULL
	,[hr_since_full] [int] NULL
	,[LastDifferential] [datetime] NULL
	,[hr_since_diff] [int] NULL
	,[LastLog] [datetime] NULL
	,[min_since_log] [int] NULL
	,[compatibility_level] [tinyint] NOT NULL
	,[state_desc] [nvarchar](60) NULL
	,[user_access_desc] [nvarchar](60) NULL
	,[recovery_model_desc] [nvarchar](60) NULL
	,[log_reuse_wait_desc] [nvarchar](60) NULL
	);

INSERT INTO #Temp1
SELECT backupset.database_name
	,MAX(CASE 
			WHEN backupset.type = 'D'
				THEN backupset.backup_finish_date
			ELSE NULL
			END) AS LastFullBackup
	,MAX(CASE 
			WHEN backupset.type = 'I'
				THEN backupset.backup_finish_date
			ELSE NULL
			END) AS LastDifferential
	,MAX(CASE 
			WHEN backupset.type = 'L'
				THEN backupset.backup_finish_date
			ELSE NULL
			END) AS LastLog
	,DATEDIFF(HOUR, MAX(CASE 
				WHEN backupset.type = 'D'
					THEN backupset.backup_finish_date
				ELSE NULL
				END), getdate()) hr_since_full
	,DATEDIFF(HOUR, MAX(CASE 
				WHEN backupset.type = 'I'
					THEN backupset.backup_finish_date
				ELSE NULL
				END), getdate()) hr_since_diff
	,DATEDIFF(MINUTE, MAX(CASE 
				WHEN backupset.type = 'L'
					THEN backupset.backup_finish_date
				ELSE NULL
				END), getdate()) min_since_log
FROM msdb.dbo.backupset
WHERE [user_name] != 'NT AUTHORITY\SYSTEM'
GROUP BY backupset.database_name;

IF CAST(LEFT(CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')), 2) AS INT) < 11
BEGIN
	INSERT INTO #Temp2
	SELECT CAST(SERVERPROPERTY('productversion') AS VARCHAR(max)) AG
		,name
		,CASE 
			WHEN (
					hr_since_diff < 24
					OR hr_since_full < 24
					)
				THEN 'OK'
			ELSE 'NO'
			END backup_state
		,LastFullBackup
		,hr_since_full
		,LastDifferential
		,hr_since_diff
		,LastLog
		,min_since_log
		,compatibility_level
		,state_desc
		,user_access_desc
		,recovery_model_desc
		,log_reuse_wait_desc
	FROM sys.databases sd
	LEFT JOIN #Temp1 d1 ON sd.name = d1.database_name;
END

IF CAST(LEFT(CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')), 2) AS INT) >= 11
BEGIN
	INSERT INTO #Temp2
	SELECT CASE 
			WHEN SERVERPROPERTY('IsHadrEnabled') = 1
				THEN (
						SELECT ars.role_desc
						FROM master.sys.dm_hadr_availability_replica_states ars
							,master.sys.availability_databases_cluster dc
						WHERE ars.group_id = dc.group_id
							AND ars.is_local = 1
							AND dc.database_name = name
						)
			END AG
		,name
		,CASE 
			WHEN (
					hr_since_diff < 24
					OR hr_since_full < 24
					)
				THEN 'OK'
			ELSE 'NO'
			END backup_state
		,LastFullBackup
		,hr_since_full
		,LastDifferential
		,hr_since_diff
		,LastLog
		,min_since_log
		,compatibility_level
		,state_desc
		,user_access_desc
		,recovery_model_desc
		,log_reuse_wait_desc
	FROM sys.databases sd
	LEFT JOIN #Temp1 d1 ON sd.name = d1.database_name;
END

SELECT *
FROM #Temp2
WHERE name != 'tempdb'
	AND backup_state != 'OK'
--AND AG ='PRIMARY'
ORDER BY hr_since_full DESC
