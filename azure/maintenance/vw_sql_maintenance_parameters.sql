CREATE VIEW [sqldba].vw_sql_maintenance_parameters
AS 
SELECT [Server_Name],[Databases],'DECLARE @sql_db VARCHAR(max)
								  SET @sql_db = ( SELECT DB_NAME(db_id()))
								  EXECUTE [sqldba].[IndexOptimize]	@Databases = @sql_db,
											@FragmentationLow =''' + CAST(ISNULL([FragmentationLow], 'NULL') AS NVARCHAR(max)) + ''', 
											@FragmentationMedium = ''' + CAST(ISNULL([FragmentationMedium], 'NULL') AS NVARCHAR(max)) + ''',
											@FragmentationHigh = ''' + CAST(ISNULL([FragmentationHigh], 'NULL') AS NVARCHAR(max)) + ''',  
											@FragmentationLevel1 = ' + ISNULL(CAST([FragmentationLevel1] AS NVARCHAR(max)), 'NULL') + ', 
											@FragmentationLevel2 = ' + ISNULL(CAST([FragmentationLevel2] AS NVARCHAR(max)), 'NULL') + ' , 
											@MinNumberOfPages = ' + ISNULL(CAST([MinNumberOfPages] AS NVARCHAR(max)), 'NULL') + ', 
											@MaxNumberOfPages = ' + ISNULL(CAST([MaxNumberOfPages] AS NVARCHAR(max)), 'NULL') + ', 
											@SortInTempdb = ''' + CAST(ISNULL([SortInTempdb], 'NULL') AS NVARCHAR(max)) + ''', 
											@MaxDOP = ' + ISNULL(CAST([Max_DOP] AS NVARCHAR(max)), 'NULL') + ', 
											@FillFactor = ' + ISNULL(CAST([Fill_Factor] AS NVARCHAR(max))		, 'NULL') + ', 
											@PadIndex = ' + CAST(ISNULL([PadIndex], 'NULL') AS NVARCHAR(max)) + ', 
											@LOBCompaction = ''' + CAST(ISNULL([LOBCompaction], 'NULL') AS NVARCHAR(max)) + ''', 
											@UpdateStatistics = ' + CAST(ISNULL([UpdateStatistics], 'NULL') AS NVARCHAR(max)) + ', 
											@OnlyModifiedStatistics = ''' + CAST(ISNULL([OnlyModifiedStatistics], 'NULL') AS NVARCHAR(max)) + ''', 
											@StatisticsModificationLevel = ' + ISNULL(CAST([StatisticsModificationLevel] AS NVARCHAR(max)), 'NULL') + ', 
											@StatisticsSample = ' + ISNULL(CAST([StatisticsSample] AS NVARCHAR(max)), 'NULL') + ', 
											@StatisticsResample = ''' + CAST(ISNULL([StatisticsResample], 'NULL') AS NVARCHAR(max)) + ''', 
											@PartitionLevel = ''' + CAST(ISNULL([PartitionLevel], 'NULL') AS NVARCHAR(max)) + ''', 
											@MSShippedObjects = ''' + CAST(ISNULL([MSShippedObjects], 'NULL') AS NVARCHAR(max)) + ''', 
											@Indexes = ''' + CAST(ISNULL([Indexes], 'NULL') AS NVARCHAR(max)) + ''', 
											@TimeLimit = ' + ISNULL(CAST([TimeLimit]	AS NVARCHAR(max)), 'NULL') + ', 
											@Delay = ' + ISNULL(CAST([Delay] AS NVARCHAR(max)), 'NULL') + ', 
											@WaitAtLowPriorityMaxDuration = ' + ISNULL(CAST([WaitAtLowPriorityMaxDuration] AS NVARCHAR(max)), 'NULL') + ', 
											@WaitAtLowPriorityAbortAfterWait = ' + CAST(ISNULL([WaitAtLowPriorityAbortAfterWait], 'NULL') AS NVARCHAR(max)) + ', 
											@Resumable = ''' + CAST(ISNULL([Resumable], 'NULL') AS NVARCHAR(max)) + ''', 
											@AvailabilityGroups = ''' + CAST(ISNULL([AvailabilityGroups], 'NULL') AS NVARCHAR(max)) + ''', 
											@LockTimeout = ' + ISNULL(CAST([LockTimeout] AS NVARCHAR(max)), 'NULL') + ', 
											@LockMessageSeverity = ' + ISNULL(CAST([LockMessageSeverity] AS NVARCHAR(max)), 'NULL') + ', 
											@StringDelimiter = ''' + CAST(ISNULL([StringDelimiter], 'NULL') AS NVARCHAR(max)) + ''', 
											@DatabaseOrder = ' + CAST(ISNULL([DatabaseOrder], 'NULL') AS NVARCHAR(max)) + ', 
											@DatabasesInParallel = ''' + CAST(ISNULL([DatabasesInParallel], 'NULL') AS NVARCHAR(max)) + ''', 
											@LogToTable = ''' + CAST(ISNULL([LogToTable], 'NULL') AS NVARCHAR(max)) + '''
											' AS Script
FROM [az].[sqldba].[sql_maintenance_parameters]
