DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
DBCC FREESYSTEMCACHE ('ALL')

EXECUTE AS login='sa';

/* Enable Trace Flags 1204 and 1222 at global level  */

DBCC TRACEON (1204,-1)
GO
DBCC TRACEON (1222,-1)
GO

/* Second Option Enabling Trace Flags 1204 and 1222 using DBCC TRACEON Statement at global level */

DBCC TRACEON (1204, 1222, -1);

/* Disable Trace Flags 1204 and 1222 at global level */

DBCC TRACEOFF (1204,-1);
DBCC TRACEOFF (1222,-1);

/* Second Option Disable Trace Flags 1204 and 1222 using single DBCC TRACEON Statement at global level */

DBCC TRACEOFF (1204, 1222, -1);

select max(last_batch),min(last_batch),DATEADD(HOUR, -5, GETDATE()),DATEADD(HOUR, 5, GETDATE())
 from sys.sysprocesses
where loginame='DOMAIN\XXXX'
and status ='sleeping' and last_batch < DATEADD(HOUR, -24, GETDATE())

SELECT 'KILL ' + cast(spid AS VARCHAR(max)) + ';'
	,*
FROM sys.sysprocesses
WHERE dbid IN (
		SELECT database_id
		FROM sys.databases
		WHERE name = 'DB_Name' --change
		)

-- Multi Value SP --
SELECT T.C.value('.', 'NVARCHAR(20)') AS [ID]
INTO #TempNHI
FROM (
	SELECT CAST('<ID>' + REPLACE(@Local_ID, ',', '</ID><ID>') + '</ID>' AS XML) AS [IDs]
	) AS A
CROSS APPLY IDs.nodes('/ID') AS T(C);

---- Stuck in Single User Mode ---- 


SET DEADLOCK_PRIORITY high;

ALTER DATABASE [DBATools]
SET OFFLINE;

ALTER DATABASE [DBATools]
SET MULTI_USER;

ALTER DATABASE [DBATools]
SET ONLINE;

------------------------------------------------------------------------

SELECT SERVERPROPERTY('MachineName') MachineName
	,SERVERPROPERTY('productversion') productversion
	,SUBSTRING(cast(@@VERSION AS VARCHAR(max)), 1, CHARINDEX(CAST(SERVERPROPERTY('productversion') AS VARCHAR(max)), cast(@@VERSION AS VARCHAR(max)), 1) + len(CAST(SERVERPROPERTY('productversion') AS VARCHAR(max)))) Version
WHERE SERVERPROPERTY('MachineName') =''
------------------------------------------------------------------------
exec xp_cmdshell 'powershell -command "([adsi]''WinNT://Domain/#USERNAME#,user'').ChangePassword(''oldpassword'',''newpassword'')"'


-----------------------

	,CASE 
		WHEN patindex(@Pattern_1 COLLATE Latin1_General_BIN, CAST([Description] AS VARCHAR(max))) > 0
			THEN CAST(Stuff(REPLACE(REPLACE(REPLACE(REPLACE(cast([Description] as nvarchar(max)), CHAR(13), ' '), CHAR(10), ' '),'|~',''),'^^'+CHAR(13)+CHAR(10),' '), PatIndex(@Pattern_1, REPLACE(REPLACE(REPLACE(REPLACE(cast([Description] as nvarchar(max)), CHAR(13), ' '), CHAR(10), ' '),'|~',''),'^^'+CHAR(13)+CHAR(10),' ')	), 0, '') AS varchar(max))
		ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(cast([Description] as nvarchar(max)), CHAR(13), ' '), CHAR(10), ' '),'|~',''),'^^'+CHAR(13)+CHAR(10),' ')	AS varchar(max))
		END [Description]
