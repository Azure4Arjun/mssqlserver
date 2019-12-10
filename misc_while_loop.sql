--Method 1 : 

DECLARE @Archive_Rows INT;

SET @Archive_Rows = 1;

WHILE (@Archive_Rows > 0)
  BEGIN
    DELETE TOP (10000) Audit
    OUTPUT deleted.*
    INTO AuditArchive
    WHERE EVENTYEAR = '2016';

    SET @Archive_Rows = @@ROWCOUNT;
  END
  
  
--Method 2 :
  
DECLARE @TopSize INT = 10000
DECLARE @BatchSize INT = 10000
DECLARE @MaxLimit INT = 1
DECLARE @RowCount INT = 0

BEGIN TRY
    WHILE (@TopSize <= @MaxLimit)
    BEGIN
        DELETE TOP ((@TopSize) Audit
    OUTPUT deleted.*
    INTO AuditArchive
    WHERE EVENTYEAR = '2016';

        SET @RowCount = @@RowCount

        --PRINT @TopSize
        IF (
                @RowCount = 0
                OR @RowCount IS NULL
                )
            BREAK;
        ELSE
            SET @TopSize = @TopSize + @BatchSize
    END
END TRY

BEGIN CATCH
    --catch error
END CATCH
