SELECT percent_complete
	,convert(VARCHAR, DATEADD(MS, estimated_completion_time, 0), 108) AS remaining
	,dateadd(MS, estimated_completion_time, GETDATE()) AS ETA
	,(
		SELECT SUBSTRING(TEXT, statement_start_offset / 2, CASE 
					WHEN statement_end_offset = - 1
						THEN 1000
					ELSE (statement_end_offset - statement_start_offset) / 2
					END)
		FROM sys.dm_exec_sql_text(sql_handle)
		) AS command
	,*
	,session_id
	,start_time
	,command
FROM sys.dm_exec_requests
WHERE percent_complete <> 0
