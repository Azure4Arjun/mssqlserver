--https://blog.sqlauthority.com/2016/10/25/sql-server-sql-agent-jobs-running-specific-time/--

DECLARE @Target_Job_time DATETIME = '2016-06-21 11:00:00.000';

SELECT *
FROM (
	SELECT JobName
		,RunStart
		,DATEADD(second, RunSeconds, RunStart) RunEnd
		,RunSeconds
	FROM (
		SELECT j.name AS 'JobName'
			,msdb.dbo.agent_datetime(run_date, run_time) AS 'RunStart'
			,((jh.run_duration / 1000000) * 86400) + (((jh.run_duration - ((jh.run_duration / 1000000) * 1000000)) / 10000) * 3600) + (((jh.run_duration - ((jh.run_duration / 10000) * 10000)) / 100) * 60) + (jh.run_duration - (jh.run_duration / 100) * 100) RunSeconds
		FROM msdb.dbo.sysjobs j
		INNER JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
		WHERE jh.step_id = 0 --The Summary Step
		) AS H
	) AS H2
WHERE @Target_Job_time BETWEEN RunStart
		AND RunEnd
ORDER BY JobName
	,RunEnd
------------------------------------------

SELECT *
FROM (
	SELECT JobName
		,RunStart
		,DATEADD(second, RunSeconds, RunStart) RunEnd
		,RunSeconds/60 RunMin
	FROM (
		SELECT j.name AS 'JobName'
			,msdb.dbo.agent_datetime(run_date, run_time) AS 'RunStart'
			,((jh.run_duration / 1000000) * 86400) + (((jh.run_duration - ((jh.run_duration / 1000000) * 1000000)) / 10000) * 3600) + (((jh.run_duration - ((jh.run_duration / 10000) * 10000)) / 100) * 60) + (jh.run_duration - (jh.run_duration / 100) * 100) RunSeconds
		FROM msdb.dbo.sysjobs j
		INNER JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
		WHERE jh.step_id = 0 --The Summary Step
		) AS H
	) AS H2
where ((DATEPART(hour,RunStart) between 2 and 8) or (DATEPART(hour,RunEnd) between 2 and 8))
and  (CAST(RunStart as date) in ('2019-07-29','2019-07-28') or CAST(RunEnd as date) in ('2019-07-29','2019-07-28') )
order by RunStart DESC
