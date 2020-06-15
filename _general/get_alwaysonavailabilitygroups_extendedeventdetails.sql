;

WITH cte_HADR
AS (
	SELECT object_name
		,CONVERT(XML, event_data) AS data
	FROM sys.fn_xe_file_target_read_file('AlwaysOn*.xel', NULL, NULL, NULL)
		WHERE object_name != 'hadr_db_partner_set_sync_state'
	)
SELECT object_name
	,DATEADD( hour,12,data.value('(/event/@timestamp)[1]', 'datetime')) AS [timestamp] --NZT
	,data.value('(/event/data[@name=''error_number''])[1]', 'varchar(max)') AS previous_state
	,data.value('(/event/data[@name=''previous_state''])[1]', 'varchar(max)') AS previous_state
	,data.value('(/event/data[@name=''current_state''])[1]', 'varchar(max)') AS current_state
	,data.value('(/event/data[@name=''availability_group_name''])[1]', 'varchar(max)') AS availability_group_name
	,data.value('(/event/data[@name=''availability_replica_name''])[1]', 'varchar(max)') AS availability_replica_name
	,data.value('(/event/data[@name=''message''])[1]', 'varchar(max)') AS [message]
FROM cte_HADR
WHERE data.value('(/event/@timestamp)[1]', 'datetime') > getdate() - 30
and object_name like 'availability_replica%'
ORDER BY data.value('(/event/@timestamp)[1]', 'datetime') ASC
