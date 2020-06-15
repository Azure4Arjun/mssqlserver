SELECT e.name AS mirror_endpoint_name
	,s.name AS login_name
	,p.permission_name
	,p.state_desc AS permission_state
	,e.state_desc endpoint_state
FROM sys.server_permissions p
INNER JOIN sys.endpoints e ON p.major_id = e.endpoint_id
INNER JOIN sys.server_principals s ON p.grantee_principal_id = s.principal_id
WHERE p.class_desc = 'ENDPOINT'
	AND e.type_desc = 'DATABASE_MIRRORING'

SELECT r.replica_server_name
	,r.endpoint_url
	,rs.connected_state_desc
	,rs.last_connect_error_description
	,rs.last_connect_error_number
	,rs.last_connect_error_timestamp
FROM sys.dm_hadr_availability_replica_states rs
JOIN sys.availability_replicas r ON rs.replica_id = r.replica_id
WHERE rs.is_local = 1
