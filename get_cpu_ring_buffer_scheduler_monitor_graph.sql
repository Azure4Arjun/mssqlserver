DECLARE @gc VARCHAR(MAX)
	,@gi VARCHAR(MAX);

WITH BR_Data
AS (
	SELECT TIMESTAMP
		,CONVERT(XML, record) AS record
	FROM sys.dm_os_ring_buffers
	WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
		AND record LIKE '%<SystemHealth>%'
	)
	,Extracted_XML
AS (
	SELECT TIMESTAMP
		,record.value('(./Record/@id)[1]', 'int') AS record_id
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'bigint') AS SystemIdle
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'bigint') AS SQLCPU
	FROM BR_Data
	)
	,CPU_Data
AS (
	SELECT record_id
		,ROW_NUMBER() OVER (
			ORDER BY record_id
			) AS rn
		,dateadd(ms, - 1 * (
				(
					SELECT ms_ticks
					FROM sys.dm_os_sys_info
					) - [TIMESTAMP]
				), GETDATE()) AS EventTime
		,SQLCPU
		,SystemIdle
		,100 - SystemIdle - SQLCPU AS OtherCPU
	FROM Extracted_XML
	)
SELECT @gc = CAST((
			SELECT CAST(d1.rn AS VARCHAR) + ' ' + CAST(d1.SQLCPU AS VARCHAR) + ','
			FROM CPU_Data AS d1
			ORDER BY d1.rn
			FOR XML PATH('')
			) AS VARCHAR(MAX))
	,@gi = CAST((
			SELECT CAST(d1.rn AS VARCHAR) + ' ' + CAST(d1.OtherCPU AS VARCHAR) + ','
			FROM CPU_Data AS d1
			ORDER BY d1.rn
			FOR XML PATH('')
			) AS VARCHAR(MAX))
OPTION (RECOMPILE);

SELECT CAST('LINESTRING(' + LEFT(@gc, LEN(@gc) - 1) + ')' AS GEOMETRY)
	,'SQL CPU %' AS Measure

UNION ALL

SELECT CAST('LINESTRING(1 100,2 100)' AS GEOMETRY)
	,''

UNION ALL

SELECT CAST('LINESTRING(' + LEFT(@gi, LEN(@gi) - 1) + ')' AS GEOMETRY)
	,'Other CPU %';
