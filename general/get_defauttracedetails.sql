https://www.mssqltips.com/sqlservertip/3445/using-the-sql-server-default-trace-to-audit-events/

--###List all traces in the server
SELECT * FROM sys.traces
SELECT * FROM sys.traces WHERE is_default = 1

--###Default Trace captures details of 34 events 

DECLARE @id INT

SELECT @id=id FROM sys.traces WHERE is_default = 1

SELECT DISTINCT eventid, name 
FROM  fn_trace_geteventinfo(@id) EI
JOIN sys.trace_events TE  
ON EI.eventid = TE.trace_event_id  

--###Find Captured Trace Events and Occurrence

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

SELECT TE.name AS EventName, DT.DatabaseName, DT.ApplicationName, 
DT.LoginName, COUNT(*) AS Quantity 
FROM dbo.fn_trace_gettable (@path,  DEFAULT) DT 
INNER JOIN sys.trace_events TE 
ON DT.EventClass = TE.trace_event_id 
GROUP BY TE.name , DT.DatabaseName , DT.ApplicationName, DT.LoginName 
ORDER BY TE.name, DT.DatabaseName , DT.ApplicationName, DT.LoginName 

--###SQL Server Auto Grow Information
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Database: Data & Log File Auto Grow
SELECT DatabaseName, [FileName],
CASE EventClass WHEN 92 THEN 'Data File Auto Grow'   
 WHEN 93 THEN 'Log File Auto Grow'END AS EventClass,
Duration, StartTime, EndTime, SPID, ApplicationName, LoginName 
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (92,93)
ORDER BY StartTime DESC

--###SQL Server Data and Log File Shrinks 

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Database: Data & Log File Shrink
SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (116) AND TextData like 'DBCC%SHRINK%'
ORDER BY StartTime DESC

--###Finding When SQL Server DBCC Commands Were Run
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Security Audit: Audit DBCC CHECKDB, DBCC CHECKTABLE, DBCC CHECKCATALOG,
--DBCC CHECKALLOC, DBCC CHECKFILEGROUP Events, and more.
SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (116) AND TextData like 'DBCC%CHECK%'
ORDER BY StartTime DESC

--###When SQL Server Backups Occurred
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Security Audit: Audit Backup Event
SELECT DatabaseName, TextData, Duration, StartTime, EndTime,
SPID, ApplicationName, LoginName   
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (115) and EventSubClass=1
ORDER BY StartTime DESC

--###When SQL Server Restores Occurred

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Security Audit: Audit Restore Event
SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName     
 FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (115) and EventSubClass=2
ORDER BY StartTime DESC

--###Find SQL Server Errors for Hash Warnings

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Errors and Warnings: Hash Warning
SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (55)
ORDER BY StartTime DESC


--###Find SQL Server Errors for Missing Column Statistics
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Errors and Warnings: Missing Column Statistics
SELECT DatabaseName, TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName 
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE  EventClass IN (79)
ORDER BY StartTime DESC;

--###Find SQL Server Errors for Missing Join Predicates
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Errors and Warnings: Missing Join Predicate
SELECT DatabaseName,TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (80)
ORDER BY  StartTime DESC

--###Find SQL Server Errors for Sort Warnings
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Errors and Warnings: Sort Warnings
SELECT DatabaseName, TextData, Duration, StartTime, EndTime, 
SPID, ApplicationName, LoginName   
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (69)
ORDER BY StartTime DESC

--###Find SQL Server Errors for the ErrorLog
DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Errors and Warnings: ErrorLog
SELECT TextData, Duration, StartTime, EndTime, SPID, ApplicationName, LoginName   
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (22)
ORDER BY StartTime DESC

--###Adding and Finding SQL Server Auto Statistics Events 

DECLARE @path NVARCHAR(260)

SELECT @path=path FROM sys.traces WHERE is_default = 1

--Auto Stats, Indicates an automatic updating of index statistics has occurred.
SELECT TextData, ObjectID, ObjectName, IndexID, Duration, StartTime, EndTime, 
SPID, ApplicationName, LoginName  
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (58)
ORDER BY StartTime DESC





