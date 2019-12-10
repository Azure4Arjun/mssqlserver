SELECT 'USE ' + publisher_db + '; EXEC sp_changepublication @publication=''' + publication + ''',@property = N''allow_anonymous'',@value=''FALSE'' ;'+' USE ' + publisher_db + '; EXEC sp_changepublication @publication=''' + publication + ''',@property = N''immediate_sync'',@value=''FALSE'' ;'
	,immediate_sync
	,*
FROM distribution.dbo.MSpublications
WHERE immediate_sync = 1
