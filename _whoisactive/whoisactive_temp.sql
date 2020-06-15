CREATE TABLE #Temp1 (
	c1 DATETIME
	,c2 VARCHAR(50)
	,c3 INT
	);

INSERT INTO #temp1
EXEC [dbo].[sp_whoisactive_blk] @blk_hr = 24;
