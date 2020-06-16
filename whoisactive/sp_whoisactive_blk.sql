USE [DBATools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_whoisactive_blk] @blk_hr INT = 4
	,@blk_db NVARCHAR(128) = NULL
AS
/*
 EXEC DBATools.[dbo].[sp_whoisactive_blk] @blk_hr= 24 ,@blk_db='DB_Name' 

*/
SELECT [collection_time]
	,[Database_name]
	,count(*) [Count]
FROM [DBATools].[dbo].[WhoIsActive]
WHERE blocking_session_id IS NOT NULL
	AND collection_time >= DATEADD(HOUR, - @blk_hr, GETDATE())
	AND (
		database_name = @blk_db
		OR @blk_db IS NULL
		)
GROUP BY [collection_time]
	,[Database_name]
ORDER BY [collection_time] DESC
	,[Database_name] DESC
GO


