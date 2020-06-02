DECLARE @sql_db VARCHAR(max)
SET @sql_db = ( SELECT DB_NAME(db_id()))

EXECUTE [sqldba].[IndexOptimize] @Databases = sql_db
	,@UpdateStatistics = 'ALL'
	,@OnlyModifiedStatistics = 'Y'
	,@StatisticsSample = 100
	,@LogToTable = 'Y'
