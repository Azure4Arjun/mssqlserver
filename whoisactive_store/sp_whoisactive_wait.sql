USE [DBATools]
GO

/****** Object:  StoredProcedure [dbo].[sp_whoisactive_wait]    Script Date: 07/03/2019 11:05:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_whoisactive_wait] @wait_hr INT = 2
	,@wait_db NVARCHAR(128) = NULL
	,@wait_info NVARCHAR(128) = NULL
AS
/*
 EXEC DBATools.[dbo].[sp_whoisactive_wait] @wait_hr= 1 ,@wait_db=NULL ,@wait_info = NULL

*/
SELECT [collection_time] [collection_time]
	,database_name
	,STATUS [status]
	,substring(wait_info, charindex(')', wait_info) + 1, len(wait_info)) [wait_type]
	,count(*) [count]
FROM [dbo].[WhoIsActive]
WHERE collection_time >= DATEADD(HOUR, - @wait_hr, GETDATE())
	AND substring(wait_info, charindex(')', wait_info) + 1, len(wait_info)) IS NOT NULL
	AND (
		database_name = @wait_db
		OR @wait_db IS NULL
		)
	AND (
		substring(wait_info, charindex(')', wait_info) + 1, len(wait_info)) = @wait_info
		OR @wait_info IS NULL
		)
GROUP BY [collection_time]
	,database_name
	,STATUS
	,substring(wait_info, charindex(')', wait_info) + 1, len(wait_info))
ORDER BY [collection_time] DESC
	,database_name
	,STATUS
GO


