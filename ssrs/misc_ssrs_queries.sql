USE ReportServer
GO

/* Active Reports */

SELECT runningjobs.computername [Servername]
	,runningjobs.RequestPath
	,runningjobs.startdate
	,users.username
	,Datediff(s, runningjobs.startdate, Getdate()) / 60 AS [Active_Minutes]
FROM runningjobs WITH (NOLOCK)
INNER JOIN users WITH (NOLOCK)
	ON runningjobs.userid = users.userid
ORDER BY runningjobs.startdate ASC

/* Subscription Queue */
		  
SELECT *
FROM dbo.Notifications n WITH (NOLOCK)
INNER JOIN dbo.CATALOG c
WITH (NOLOCK)
	ON n.ReportID = c.ItemID
INNER JOIN dbo.Users u WITH (NOLOCK)
	ON n.SubscriptionOwnerID = u.UserID
WHERE n.ProcessStart IS NULL
	AND (
		n.ProcessAfter IS NULL
		OR n.ProcessAfter < GETDATE()
		)

/* This provides a basic layer of the reports, folders, and other objects that make up the folder structure of the Report Server. */
SELECT CASE 
		WHEN C.Name = ''
			THEN 'Home'
		ELSE C.Name
		END AS ItemName
	,C.Description AS Report_Description
	,LEN(C.Path) - LEN(REPLACE(C.Path, '/', '')) AS ItemLevel
	,CASE 
		WHEN C.type = 1
			THEN '1-Folder'
		WHEN C.type = 2
			THEN '2-Report'
		WHEN C.type = 3
			THEN '3-File'
		WHEN C.type = 4
			THEN '4-Linked Report'
		WHEN C.type = 5
			THEN '5-Datasource'
		WHEN C.type = 6
			THEN '6-Model'
		WHEN C.type = 7
			THEN '7-ReportPart'
		WHEN C.type = 8
			THEN '8-Shared Dataset'
		ELSE '9-Unknown'
		END AS ItemType
	,CASE 
		WHEN C.Path = ''
			THEN 'Home'
		ELSE C.Path
		END AS Path
	,ISNULL(CASE 
			WHEN CP.Name = ''
				THEN 'Home'
			ELSE CP.Name
			END, 'Home') AS ParentName
	,ISNULL(LEN(CP.Path) - LEN(REPLACE(CP.Path, '/', '')), 0) AS ParentLevel
	,ISNULL(CASE 
			WHEN CP.Path = ''
				THEN ' Home'
			ELSE CP.Path
			END, ' Home') AS ParentPath
FROM dbo.CATALOG AS CP
RIGHT JOIN dbo.CATALOG AS C
	ON CP.ItemID = C.ParentID

/* This provides more report level detail about a reports including who created and modified it, when was it last executed and conveys some basic subscription details. 
Scott Herbent's SQL Ninja blog provided the initial basis for this query, although extensive modification has been made..*/
USE ReportServer
GO

SELECT CAT_PARENT.Name AS ParentName
	,CAT.Name AS ReportName
	,ReportCreatedByUsers.UserName AS ReportCreatedByUserName
	,CAT.CreationDate AS ReportCreationDate
	,ReportModifiedByUsers.UserName AS ReportModifiedByUserName
	,CAT.ModifiedDate AS ReportModifiedDate
	,CountExecution.CountStart AS ReportExecuteCount
	,EL.InstanceName AS LastExecutedServerName
	,EL.UserName AS LastExecutedbyUserName
	,EL.TimeStart AS LastExecutedTimeStart
	,EL.TimeEnd AS LastExecutedTimeEnd
	,EL.STATUS AS LastExecutedStatus
	,EL.ByteCount AS LastExecutedByteCount
	,EL.[RowCount] AS LastExecutedRowCount
	,SubscriptionOwner.UserName AS SubscriptionOwnerUserName
	,SubscriptionModifiedByUsers.UserName AS SubscriptionModifiedByUserName
	,SUB.ModifiedDate AS SubscriptionModifiedDate
	,SUB.Description AS SubscriptionDescription
	,SUB.LastStatus AS SubscriptionLastStatus
	,SUB.LastRunTime AS SubscriptionLastRunTime
FROM dbo.CATALOG CAT
INNER JOIN dbo.CATALOG CAT_PARENT
	ON CAT.ParentID = CAT_PARENT.ItemID
INNER JOIN dbo.Users ReportCreatedByUsers
	ON CAT.CreatedByID = ReportCreatedByUsers.UserID
INNER JOIN dbo.Users ReportModifiedByUsers
	ON CAT.ModifiedByID = ReportModifiedByUsers.UserID
LEFT JOIN (
	SELECT ReportID
		,MAX(TimeStart) LastTimeStart
	FROM dbo.ExecutionLog
	GROUP BY ReportID
	) AS LatestExecution
	ON CAT.ItemID = LatestExecution.ReportID
LEFT JOIN (
	SELECT ReportID
		,COUNT(TimeStart) CountStart
	FROM dbo.ExecutionLog
	GROUP BY ReportID
	) AS CountExecution
	ON CAT.ItemID = CountExecution.ReportID
LEFT JOIN dbo.ExecutionLog AS EL
	ON LatestExecution.ReportID = EL.ReportID
		AND LatestExecution.LastTimeStart = EL.TimeStart
LEFT JOIN dbo.Subscriptions SUB
	ON CAT.ItemID = SUB.Report_OID
LEFT JOIN dbo.Users SubscriptionOwner
	ON SUB.OwnerID = SubscriptionOwner.UserID
LEFT JOIN dbo.Users SubscriptionModifiedByUsers
	ON SUB.ModifiedByID = SubscriptionModifiedByUsers.UserID
ORDER BY CAT_PARENT.Name
	,CAT.Name

/* This provides the scheduling details for our subscription and the related SQLAgent JobID. The SQLAgent JobID can be used to run the "Subscription on an adhoc basis or for 1 time report runs.*/

USE REPORTSERVER
GO

CAT.itemid
	,REP_SCH.reportID
	,CAT.Name AS 'ReportName'
	,sub.Report_OID
	,REP_SCH.ScheduleID AS 'SQLJobID'
	,CASE SCH.recurrencetype
		WHEN 1
			THEN 'Once'
		WHEN 3
			THEN CASE SCH.daysinterval
					WHEN 1
						THEN 'Every day'
					ELSE 'Every other ' + CAST(SCH.daysinterval AS VARCHAR) + ' day.'
					END
		WHEN 4
			THEN CASE SCH.daysofweek
					WHEN 1
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Sunday'
					WHEN 2
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Monday'
					WHEN 4
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Tuesday'
					WHEN 8
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Wednesday'
					WHEN 16
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Thursday'
					WHEN 32
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Friday'
					WHEN 64
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Saturday'
					WHEN 42
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Monday, Wednesday, and Friday'
					WHEN 62
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on Monday, Tuesday, Wednesday, Thursday and Friday'
					WHEN 126
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week from Monday to Saturday'
					WHEN 127
						THEN 'Every ' + CAST(SCH.weeksinterval AS VARCHAR) + ' week on every day'
					END
		WHEN 5
			THEN CASE SCH.daysofmonth
					WHEN 1
						THEN 'Day ' + '1' + ' of each month'
					WHEN 2
						THEN 'Day ' + '2' + ' of each month'
					WHEN 4
						THEN 'Day ' + '3' + ' of each month'
					WHEN 8
						THEN 'Day ' + '4' + ' of each month'
					WHEN 16
						THEN 'Day ' + '5' + ' of each month'
					WHEN 32
						THEN 'Day ' + '6' + ' of each month'
					WHEN 64
						THEN 'Day ' + '7' + ' of each month'
					WHEN 128
						THEN 'Day ' + '8' + ' of each month'
					WHEN 256
						THEN 'Day ' + '9' + ' of each month'
					WHEN 512
						THEN 'Day ' + '10' + ' of each month'
					WHEN 1024
						THEN 'Day ' + '11' + ' of each month'
					WHEN 2048
						THEN 'Day ' + '12' + ' of each month'
					WHEN 4096
						THEN 'Day ' + '13' + ' of each month'
					WHEN 8192
						THEN 'Day ' + '14' + ' of each month'
					WHEN 16384
						THEN 'Day ' + '15' + ' of each month'
					WHEN 32768
						THEN 'Day ' + '16' + ' of each month'
					WHEN 65536
						THEN 'Day ' + '17' + ' of each month'
					WHEN 131072
						THEN 'Day ' + '18' + ' of each month'
					WHEN 262144
						THEN 'Day ' + '19' + ' of each month'
					WHEN 524288
						THEN 'Day ' + '20' + ' of each month'
					WHEN 1048576
						THEN 'Day ' + '21' + ' of each month'
					WHEN 2097152
						THEN 'Day ' + '22' + ' of each month'
					WHEN 4194304
						THEN 'Day ' + '23' + ' of each month'
					WHEN 8388608
						THEN 'Day ' + '24' + ' of each month'
					WHEN 16777216
						THEN 'Day ' + '25' + ' of each month'
					WHEN 33554432
						THEN 'Day ' + '26' + ' of each month'
					WHEN 67108864
						THEN 'Day ' + '27' + ' of each month'
					WHEN 134217728
						THEN 'Day ' + '28' + ' of each month'
					WHEN 268435456
						THEN 'Day ' + '29' + ' of each month'
					WHEN 536870912
						THEN 'Day ' + '30' + ' of each month'
					WHEN 1073741824
						THEN 'Day ' + '31' + ' of each month'
					END
		WHEN 6
			THEN 'The ' + CASE SCH.monthlyweek
					WHEN 1
						THEN 'first'
					WHEN 2
						THEN 'second'
					WHEN 3
						THEN 'third'
					WHEN 4
						THEN 'fourth'
					WHEN 5
						THEN 'last'
					ELSE 'UNKNOWN'
					END + ' week of each month on ' + CASE SCH.daysofweek
					WHEN 2
						THEN 'Monday'
					WHEN 4
						THEN 'Tuesday'
					ELSE 'Unknown'
					END
		ELSE 'Unknown'
		END + ' at ' + LTRIM(RIGHT(CONVERT(VARCHAR, SCH.StartDate, 100), 7)) AS 'ScheduleDetails'
	,SCH.RecurrenceType
	,CAT.Path AS 'ReportPath'
FROM dbo.CATALOG AS cat
INNER JOIN dbo.ReportSchedule AS REP_SCH
	ON CAT.ItemID = REP_SCH.ReportID
INNER JOIN dbo.Schedule AS SCH
	ON REP_SCH.ScheduleID = SCH.ScheduleID
INNER JOIN dbo.Subscriptions AS sub
	ON sub.SubscriptionID = REP_SCH.SubscriptionID
WHERE (LEN(CAT.Name) > 0)
--AND
--CAT.Name like 'Name of Report%' --Can add the Report Name
ORDER BY 'ReportName'

/* This provides details about the subscription report's parameters, output method and location, and the last run date.*/

USE Reportserver
GO

SELECT CAT.[Name] AS RptName
	,U.UserName
	,CAT.[Path]
	,res.ScheduleID AS JobID
	,sub.LastRuntime
	,sub.LastStatus
	,LEFT(CAST(sch.next_run_date AS CHAR(8)), 4) + '-' + SUBSTRING(CAST(sch.next_run_date AS CHAR(8)), 5, 2) + '-' + RIGHT(CAST(sch.next_run_date AS CHAR(8)), 2) + ' ' + CASE 
		WHEN LEN(CAST(sch.next_run_time AS VARCHAR(6))) = 5
			THEN '0' + LEFT(CAST(sch.next_run_time AS VARCHAR(6)), 1)
		ELSE LEFT(CAST(sch.next_run_time AS VARCHAR(6)), 2)
		END + ':' + CASE 
		WHEN LEN(CAST(sch.next_run_time AS VARCHAR(6))) = 5
			THEN SUBSTRING(CAST(sch.next_run_time AS VARCHAR(6)), 2, 2)
		ELSE SUBSTRING(CAST(sch.next_run_time AS VARCHAR(6)), 3, 2)
		END + ':00.000' AS NextRunTime
	,CASE 
		WHEN job.[enabled] = 1
			THEN 'Enabled'
		ELSE 'Disabled'
		END AS JobStatus
	,sub.ModifiedDate
	,sub.Description
	,sub.EventType
	,sub.Parameters
	,sub.DeliveryExtension
	,sub.Version
FROM dbo.CATALOG AS cat
INNER JOIN dbo.Subscriptions AS sub
	ON CAT.ItemID = sub.Report_OID
INNER JOIN dbo.ReportSchedule AS res
	ON CAT.ItemID = res.ReportID
		AND sub.SubscriptionID = res.SubscriptionID
INNER JOIN msdb.dbo.sysjobs AS job
	ON CAST(res.ScheduleID AS VARCHAR(36)) = job.[name]
INNER JOIN msdb.dbo.sysjobschedules AS sch
	ON job.job_id = sch.job_id
INNER JOIN dbo.Users U
	ON U.UserID = sub.OwnerID
ORDER BY U.UserName
	,RptName

/*The below provides information about who has access to folders and reports and describes the role / level of access the user or group have to that report.*/

USE ReportServer
GO

SELECT CAT.Name
	,U.UserName
	,ROL.RoleName
	,ROL.Description
	,U.AuthType
FROM dbo.Users U
INNER JOIN dbo.PolicyUserRole PUR ON U.UserID = PUR.UserID
INNER JOIN dbo.Policies POLICY ON POLICY.PolicyID = PUR.PolicyID
INNER JOIN dbo.Roles ROL ON ROL.RoleID = PUR.RoleID
INNER JOIN dbo.CATALOG CAT ON CAT.PolicyID = POLICY.PolicyID
WHERE [PolicyRoot] = 1 -- 0 Inherit security & 1 Not Inherit security
	AND u.UserName NOT LIKE '%'
ORDER BY CAT.Name

