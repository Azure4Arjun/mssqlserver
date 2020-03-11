WITH backupset
AS (
	SELECT bs.database_name
		,bs.type bstype
		,user_name
		,MAX(backup_finish_date) MAXbackup_finish_date
		
	FROM msdb.dbo.backupset bs
	GROUP BY bs.database_name
		,bs.type
		,user_name
	)
	,main
AS (
	SELECT db.name
		,db.state_desc
		,db.recovery_model_desc
		,bs.type
		,bs.name AS BackupSetName
		,bs.backup_finish_date
		,DATEDIFF(hour, bs.backup_finish_date, getdate()) Time_since
		,CAST(bs.backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) backup_size_GB
		,CAST(bs.compressed_backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) compressed_backup_size_GB
		,bmf.physical_device_name
		,bss.user_name
	FROM master.sys.databases db
	LEFT OUTER JOIN backupset bss ON bss.database_name = db.name
	LEFT OUTER JOIN msdb.dbo.backupset bs ON bs.database_name = db.name
	INNER JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
		AND bss.bstype = bs.type
		AND bss.MAXbackup_finish_date = bs.backup_finish_date
	)
SELECT @@servername [Server]
	,sd.name
	,m.state_desc
	,m.recovery_model_desc
	,type
	,BackupSetName
	,backup_finish_date
	,Time_since
	,backup_size_GB
	,compressed_backup_size_GB
	,physical_device_name
	,user_name
FROM sys.databases sd
LEFT JOIN main m ON sd.name = m.name
where type='D' and user_name='DCS\S-MicrosoftSQl'
ORDER BY name
	,type
	,backup_finish_date
