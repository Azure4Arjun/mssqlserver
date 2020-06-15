
/* FullText Status */

SELECT FULLTEXTCATALOGPROPERTY(cat.name, 'ItemCount') AS [ItemCount]
	,FULLTEXTCATALOGPROPERTY(cat.name, 'MergeStatus') AS [MergeStatus]
	,FULLTEXTCATALOGPROPERTY(cat.name, 'PopulateCompletionAge') AS [PopulateCompletionAge]
	,FULLTEXTCATALOGPROPERTY(cat.name, 'PopulateStatus') AS [PopulateStatus]
	,FULLTEXTCATALOGPROPERTY(cat.name, 'ImportStatus') AS [ImportStatus]
FROM sys.fulltext_catalogs AS cat

/* FullText Crawl Details */
SELECT FTCatalogName = c.name
	,TableName = t.name
	,IndexName = i.name
	,LastCrawlStart = fi.crawl_start_date
	,LastCrawlEnd = fi.crawl_end_date
--,fi.*
FROM sys.fulltext_indexes fi
INNER JOIN sys.tables t
	ON t.[object_id] = fi.[object_id]
INNER JOIN sys.fulltext_catalogs c
	ON fi.fulltext_catalog_id = c.fulltext_catalog_id
INNER JOIN sys.indexes i
	ON fi.unique_index_id = i.index_id
		AND fi.[object_id] = i.[object_id]
WHERE fi.is_enabled = 1
	AND fi.crawl_end_date < DATEADD(DAY, - 14, GETDATE())
ORDER BY fi.crawl_start_date ASC
	,t.name
	,i.name



/* Returns unprocessed changes, such as pending inserts, updates, and deletes, for a specified table that is using change tracking. */
SELECT OBJECT_ID(N'Table_Name') AS 'Object ID';

sp_fulltext_pendingchanges table_id

/* FullText Index Fragmentation Details */
WITH FragmentationDetails
AS (
	SELECT table_id
		,COUNT(*) AS FragmentsCount
		,CONVERT(DECIMAL(9, 2), SUM(data_size / (1024. * 1024.))) AS IndexSizeMb
		,CONVERT(DECIMAL(9, 2), MAX(data_size / (1024. * 1024.))) AS largest_fragment_mb
	FROM sys.fulltext_index_fragments
	GROUP BY table_id
	)
	,ft
AS (
	SELECT DB_NAME() AS DatabaseName
		,ftc.fulltext_catalog_id AS CatalogId
		,ftc.[name] AS CatalogName
		,fti.object_id AS BaseObjectId
		,QUOTENAME(OBJECT_SCHEMA_NAME(fti.object_id)) + '.' + QUOTENAME(OBJECT_NAME(fti.object_id)) AS BaseObjectName
		,unique_index_id
		,f.IndexSizeMb AS IndexSizeMb
		,f.FragmentsCount AS FragmentsCount
		,f.largest_fragment_mb AS IndexLargestFragmentMb
		,f.IndexSizeMb - f.largest_fragment_mb AS IndexFragmentationSpaceMb
		,CASE 
			WHEN f.IndexSizeMb = 0
				THEN 0
			ELSE 100.0 * (f.IndexSizeMb - f.largest_fragment_mb) / f.IndexSizeMb
			END AS IndexFragmentationPct
	FROM sys.fulltext_catalogs ftc
	INNER JOIN sys.fulltext_indexes fti
		ON fti.fulltext_catalog_id = ftc.fulltext_catalog_id
	INNER JOIN FragmentationDetails f
		ON f.table_id = fti.object_id
	)
SELECT *
FROM ft
ORDER BY IndexFragmentationPct DESC
