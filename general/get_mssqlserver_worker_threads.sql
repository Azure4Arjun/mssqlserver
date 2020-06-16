SELECT getdate() [Time_Stamp]
	,(
		SELECT max_workers_count
		FROM sys.dm_os_sys_info
		) AS 'TotalThreads'
	,sum(active_Workers_count) AS 'Currentthreads'
	,(
		SELECT max_workers_count
		FROM sys.dm_os_sys_info
		) - sum(active_Workers_count) AS 'Availablethreads'
	,sum(runnable_tasks_count) AS 'WorkersWaitingfor_cpu'
	,sum(work_queue_count) AS 'Request_Waiting_for_threads'
FROM sys.dm_os_Schedulers
WHERE STATUS = 'VISIBLE ONLINE'
