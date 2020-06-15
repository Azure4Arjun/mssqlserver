DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @edt NVARCHAR(MAX);

SET @edt = (
		SELECT GETDATE()
		);

DECLARE @esub NVARCHAR(MAX);

SELECT @esub = @@SERVERNAME + ' - SYS DB Backup - ' + @edt; --Change

SET @xml = CAST((
			SELECT Server_Name AS 'td'
				,''
				,database_name AS 'td'
				,''
				,backup_start_date AS 'td'
				,''
				,backup_finish_date AS 'td'
				,''
				,backup_type AS 'td'
				,''
				,Backup_Path AS 'td'
			FROM (
				SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server_Name
					,msdb.dbo.backupset.database_name AS database_name
					,msdb.dbo.backupset.backup_start_date AS backup_start_date
					,msdb.dbo.backupset.backup_finish_date AS backup_finish_date
					,CASE msdb..backupset.type
						WHEN 'D'
							THEN 'Database'
						WHEN 'L'
							THEN 'Log'
						END AS backup_type
					,msdb.dbo.backupmediafamily.physical_device_name AS Backup_Path
				FROM msdb.dbo.backupmediafamily
				INNER JOIN msdb.dbo.backupset
					ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
				WHERE (CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1) -- Change 
					AND msdb..backupset.type = 'D'
					AND database_name IN ( -- Change 
						'master'
						,'msdb'
						)
				) TEMP
			ORDER BY database_name
				,backup_finish_date
			FOR XML PATH('tr')
				,ELEMENTS
			) AS NVARCHAR(MAX))
SET @body = '<html><body><H3></H3>
<table border = 1> 
<tr>
<th> Server_Name </th> <th> database_name </th> <th> backup_start_date  </th><th>backup_finish_date</th><th>backup_type</th><th>Backup_Path</th></tr>'
SET @body = @body + @xml + '</table></body></html>'

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Dummy_Profile' -- Change 
	,@body = @body
	,@body_format = 'HTML'
	,@recipients = 'test@google.com' -- Change 
	,@subject = @esub;
