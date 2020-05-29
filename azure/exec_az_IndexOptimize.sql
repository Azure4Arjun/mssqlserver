DECLARE @az_db VARCHAR(max)
SET @az_db = ( SELECT DB_NAME(db_id()) )

EXECUTE [az_dba].[IndexOptimize] @Databases = @az_db
	,@UpdateStatistics = 'ALL'
	,@OnlyModifiedStatistics = 'Y'
	,@StatisticsSample = 100
	,@LogToTable = 'Y'
