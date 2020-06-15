DECLARE @full_path NVARCHAR(512)
	,@path NVARCHAR(512)
	,@name VARCHAR(max)
	,@fullname VARCHAR(max);

SELECT @full_path = path
FROM sys.traces
WHERE is_default = 1;

SELECT @path = LEFT(@full_path, LEN(@full_path) - CHARINDEX('\', REVERSE(@full_path)) + 1)

CREATE TABLE #trace_gettable (
	[TextData] [ntext] NULL
	,[BinaryData] [image] NULL
	,[DatabaseID] [int] NULL
	,[TransactionID] [bigint] NULL
	,[LineNumber] [int] NULL
	,[NTUserName] [nvarchar](256) NULL
	,[NTDomainName] [nvarchar](256) NULL
	,[HostName] [nvarchar](256) NULL
	,[ClientProcessID] [int] NULL
	,[ApplicationName] [nvarchar](256) NULL
	,[LoginName] [nvarchar](256) NULL
	,[SPID] [int] NULL
	,[Duration] [bigint] NULL
	,[StartTime] [datetime] NULL
	,[EndTime] [datetime] NULL
	,[Reads] [bigint] NULL
	,[Writes] [bigint] NULL
	,[CPU] [int] NULL
	,[Permissions] [bigint] NULL
	,[Severity] [int] NULL
	,[EventSubClass] [int] NULL
	,[ObjectID] [int] NULL
	,[Success] [int] NULL
	,[IndexID] [int] NULL
	,[IntegerData] [int] NULL
	,[ServerName] [nvarchar](256) NULL
	,[EventClass] [int] NULL
	,[ObjectType] [int] NULL
	,[NestLevel] [int] NULL
	,[State] [int] NULL
	,[Error] [int] NULL
	,[Mode] [int] NULL
	,[Handle] [int] NULL
	,[ObjectName] [nvarchar](256) NULL
	,[DatabaseName] [nvarchar](256) NULL
	,[FileName] [nvarchar](256) NULL
	,[OwnerName] [nvarchar](256) NULL
	,[RoleName] [nvarchar](256) NULL
	,[TargetUserName] [nvarchar](256) NULL
	,[DBUserName] [nvarchar](256) NULL
	,[LoginSid] [image] NULL
	,[TargetLoginName] [nvarchar](256) NULL
	,[TargetLoginSid] [image] NULL
	,[ColumnPermissions] [int] NULL
	,[LinkedServerName] [nvarchar](256) NULL
	,[ProviderName] [nvarchar](256) NULL
	,[MethodName] [nvarchar](256) NULL
	,[RowCounts] [bigint] NULL
	,[RequestID] [int] NULL
	,[XactSequence] [bigint] NULL
	,[EventSequence] [bigint] NULL
	,[BigintData1] [bigint] NULL
	,[BigintData2] [bigint] NULL
	,[GUID] [uniqueidentifier] NULL
	,[IntegerData2] [int] NULL
	,[ObjectID2] [bigint] NULL
	,[Type] [int] NULL
	,[OwnerID] [int] NULL
	,[ParentName] [nvarchar](256) NULL
	,[IsSystem] [int] NULL
	,[Offset] [int] NULL
	,[SourceDatabaseID] [int] NULL
	,[SqlHandle] [image] NULL
	,[SessionLoginName] [nvarchar](256) NULL
	,[PlanHandle] [image] NULL
	,[GroupID] [int] NULL
	,[trace_event_id] [smallint] NOT NULL
	,[category_id] [smallint] NOT NULL
	,[name] [nvarchar](128) NULL
	);

CREATE TABLE #tempdir (
	subdirectory NVARCHAR(max)
	,depth INT
	,[file] INT
	);

INSERT INTO #tempdir
EXEC xp_dirtree @path
	,2
	,1

DECLARE db_cursor CURSOR
FOR
SELECT subdirectory
FROM #tempdir
WHERE subdirectory LIKE '%.trc'

OPEN db_cursor

FETCH NEXT
FROM db_cursor
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @fullname = @path + @name;

	INSERT INTO #trace_gettable
	SELECT *
	FROM master.dbo.fn_trace_gettable(@fullname, DEFAULT) DT
	INNER JOIN sys.trace_events TE ON DT.EventClass = TE.trace_event_id

	FETCH NEXT
	FROM db_cursor
	INTO @name
END

CLOSE db_cursor

DEALLOCATE db_cursor

SELECT *
FROM #trace_gettable
ORDER BY StartTime ASC;

DROP TABLE #tempdir;
DROP TABLE #trace_gettable;
