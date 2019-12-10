USE master
GO

SELECT DISTINCT (request_owner_guid) AS UoW_Guid
	,request_session_id
	,DB_NAME(SYP.dbid)
	,SYP.loginame
	,SYP.hostname
	,SYP.STATUS
	,SYP.program_name
	,(
		SELECT TEXT
		FROM sys.dm_exec_sql_text(SYP.sql_handle)
		) AS QueryText
	,syp.lastwaittype
	,SYP.cpu
	,SYP.memusage
	,SYP.physical_io
FROM sys.dm_tran_locks DTL
INNER JOIN sys.sysprocesses SYP
	ON DTL.request_session_id = SYP.spid
WHERE request_owner_guid <> '00000000-0000-0000-0000-000000000000'
GO


