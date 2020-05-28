SELECT DB_NAME(ps.database_id) AS [Database Name]
	,SCHEMA_NAME(o.[schema_id]) AS [Schema Name]
	,OBJECT_NAME(ps.OBJECT_ID) AS [Object Name]
	,i.[name] AS [Index Name]
	,ps.index_id
	,ps.index_type_desc
	,ps.avg_fragmentation_in_percent
	,ps.fragment_count
	,ps.page_count
	,i.fill_factor
	,i.has_filter
	,i.filter_definition
	,i.[allow_page_locks]
	,ps.alloc_unit_type_desc
	,ps.object_id
	,1 [az_online]
INTO #az_index_maintenance
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, N'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON ps.[object_id] = i.[object_id]
	AND ps.index_id = i.index_id
INNER JOIN sys.objects AS o WITH (NOLOCK) ON i.[object_id] = o.[object_id]
WHERE ps.database_id = DB_ID() and  i.type in (1,2) /* 0 = Heap / 1 = Clustered / 2 = Nonclustered / 3 = XML / 4 = Spatial / 5 = Clustered columnstore index / 6 = Nonclustered columnstore index / 7 = Nonclustered hash index */
		and ps.alloc_unit_type_desc = 'IN_ROW_DATA' /* Exclude LOB_DATA or ROW_OVERFLOW_DATA*/
ORDER BY ps.avg_fragmentation_in_percent DESC , ps.page_count DESC
OPTION (RECOMPILE);

update #az_index_maintenance set az_online=0 where [object_id] in (select [object_id] from #az_index_maintenance  where index_id >=1000)

-- mark clustered indexes for tables with 'text','ntext','image' to rebuild offline

update #az_index_maintenance set az_online=0 
where index_id=1 /*clustered*/ and [object_id] in (
select object_id
from sys.columns c join sys.types t on c.user_type_id = t.user_type_id
where t.name in ('text','ntext','image')
		)
	
SELECT * FROM  #az_index_maintenance



DROP TABLE #az_index_maintenance
