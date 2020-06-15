SELECT suser_sname(owner_sid)
	,NAME
	,'ALTER AUTHORIZATION ON DATABASE::[' + NAME + '] TO [sa];'
FROM sys.databases

