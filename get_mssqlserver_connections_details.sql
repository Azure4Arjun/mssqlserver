SELECT DB_NAME(dbid) AS DBName
	,hostname
	,loginame
	,[program_name]
	,COUNT(dbid) AS NumberOfConnections
FROM sys.sysprocesses
--where hostname in ('','','')
GROUP BY dbid
	,hostname
	,loginame
	,[program_name]
ORDER BY DB_NAME(dbid)
