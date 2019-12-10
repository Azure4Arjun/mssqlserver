WITH d1
AS (
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
	GROUP BY backupset.database_name
	)
SELECT name
	,compatibility_level
	,state_desc
	,user_access_desc
	,recovery_model_desc
	,log_reuse_wait_desc
	,CASE 
		WHEN log_reuse_wait_desc = 'ACTIVE_BACKUP_OR_RESTORE'
			THEN (
					SELECT dateadd(MS, estimated_completion_time, GETDATE()) AS ETA
					FROM sys.dm_exec_requests dem
					WHERE dem.command = 'BACKUP DATABASE'
						AND dem.database_id = db_id(d1.database_name)
					)
		END Backup_estimated_completion_time
	,LastFullBackup
	,hr_since_full
	,LastDifferential
	,hr_since_diff
	,LastLog
	,min_since_log
FROM sys.databases sd
LEFT JOIN d1 ON sd.name = d1.database_name
ORDER BY hr_since_full DESC
