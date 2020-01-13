WITH backupset
AS (
	SELECT bs.database_name
		,bs.type bstype
		,MAX(backup_finish_date) MAXbackup_finish_date
	FROM msdb.dbo.backupset bs
	GROUP BY bs.database_name
		,bs.type
	)
	,Main
AS (
	SELECT db.name
		,db.state_desc
		,db.recovery_model_desc
		,bs.type
		,bs.name AS BackupSetName
		,bs.backup_finish_date
		,CAST(bs.backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) backup_size_GB
		,CAST(bs.compressed_backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) compressed_backup_size_GB
	FROM master.sys.databases db
	LEFT OUTER JOIN backupset bss ON bss.database_name = db.name
	LEFT OUTER JOIN msdb.dbo.backupset bs ON bs.database_name = db.name
		AND bss.bstype = bs.type
		AND bss.MAXbackup_finish_date = bs.backup_finish_date
	)
SELECT *
FROM Main
WHERE type = 'D'
	AND name NOT IN (
		'master'
		,'model'
		,'msdb'
		,'tempdb'
		)
