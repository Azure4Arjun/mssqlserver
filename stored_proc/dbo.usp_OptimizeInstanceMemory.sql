/* https://dba.stackexchange.com/questions/50433/max-memory-settings-on-multi-instance-sql-server-2008-r2-cluster */


CREATE PROCEDURE dbo.usp_OptimizeInstanceMemory
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @thisNode NVARCHAR(255)
		,@otherNode NVARCHAR(255)
		,@sql_1 NVARCHAR(MAX)
		,@sql_2 NVARCHAR(MAX)
		,@BalancedMemory INT;
	DECLARE @otherNodeT TABLE (name NVARCHAR(255));

	SET @thisNode = (
			SELECT CONVERT(NVARCHAR(255), SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS'))
			);
	SET @sql_1 = N'SELECT @OtherNode = CONVERT(NVARCHAR(255), 
                        SERVERPROPERTY(N''ComputerNamePhysicalNetBIOS''));';

	EXEC [Node_LinkedServer].master..sp_executesql @sql_1 -- Change Linked Server
		,N'@OtherNode NVARCHAR(255) OUTPUT'
		,@OtherNode OUTPUT;

	PRINT 'Cluster Nodes : ' + @thisnode + ' | ' + @othernode;;

	IF @thisNode = @otherNode
		SET @BalancedMemory = 13230;--Change
	ELSE
		SET @BalancedMemory = 26460;-- Change

	PRINT 'Memory to be set : ' + cast(@BalancedMemory AS NVARCHAR(max)) + 'MB';

	SET @sql_2 = 'EXEC sp_configure ''show advanced options'', 1; RECONFIGURE;
EXEC sp_configure ''max server memory'',' + cast(@BalancedMemory AS NVARCHAR(max)) + '; RECONFIGURE;  '

	PRINT @sql_2;
	PRINT 'Setting Max Memory on : ' + @thisnode;

	EXEC master..sp_executesql @sql_2

	PRINT 'Setting Max Memory on : ' + @othernode;

	EXEC [Node_LinkedServer].master..sp_executesql @sql_2 -- Change Linked Server
END
GO
									     
/* --Sets procedure for automatic executionevery time an instance of SQL Server is started.
  

EXEC [master].dbo.sp_procoption N'dbo.usp_OptimizeInstanceMemory'
	,'startup'
	,'true';
*/
									     
									     
