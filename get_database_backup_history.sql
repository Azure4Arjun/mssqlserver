SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER
	,msdb.dbo.backupset.database_name
	,msdb.dbo.backupset.backup_start_date
	,msdb.dbo.backupset.backup_finish_date
	,msdb.dbo.backupset.expiration_date
	,CASE msdb..backupset.type
		WHEN 'D'
			THEN 'Database'
		WHEN 'L'
			THEN 'Log'
		WHEN 'I'
			THEN 'Differential'
		END AS backup_type
	,CAST(msdb.dbo.backupset.backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) backup_size_GB
	,msdb.dbo.backupset.backup_size
	,msdb.dbo.backupset.compressed_backup_size
	,msdb.dbo.backupmediafamily.logical_device_name
	,msdb.dbo.backupmediafamily.physical_device_name
	,[user_name]
	,msdb.dbo.backupset.is_copy_only
	,msdb.dbo.backupset.is_snapshot
	,msdb.dbo.backupset.checkpoint_lsn
	,msdb.dbo.backupset.database_backup_lsn
	,msdb.dbo.backupset.differential_base_lsn
	,msdb.dbo.backupset.first_lsn
	,msdb.dbo.backupset.fork_point_lsn
	,msdb.dbo.backupset.last_lsn
FROM msdb.dbo.backupmediafamily
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE (CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1)
--AND msdb..backupset.type = 'L'
--AND msdb.dbo.backupset.database_name = 'master'
ORDER BY msdb.dbo.backupset.database_name
	,msdb.dbo.backupset.backup_finish_date DESC
