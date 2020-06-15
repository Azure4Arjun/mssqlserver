declare @dbname varchar(255), @stmt varchar(255)

set @dbname = 'DBATools'

-- =============================================
-- Declare and using a READ_ONLY cursor
-- =============================================
DECLARE killcursor CURSOR
READ_ONLY
FOR 
select spid from sys.sysprocesses where dbid = db_id(@dbname)

DECLARE @spid int
OPEN killcursor

FETCH NEXT FROM killcursor INTO @spid
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		select @stmt = 'kill ' + convert(varchar(10),@spid)
		print 'Running: "' + @stmt + '" in database: ' + @dbname
		exec ( @stmt )
	END
	FETCH NEXT FROM killcursor INTO @spid
END

CLOSE killcursor
DEALLOCATE killcursor
GO
