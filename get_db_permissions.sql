
/*

Script to export all database user permissons.

*/


USE MASTER
GO
 
SET NOCOUNT ON
 
DECLARE @DestDatabase VARCHAR(max)
 
SET @DestDatabase = 'Test' --DBname
 
IF EXISTS (
        SELECT *
        FROM SYSDATABASES
        WHERE name = @DestDatabase
        )
    EXEC (
            'USE ' + @DestDatabase + ';
 
DECLARE @temp table(Extract Varchar(MAX))
 
INSERT INTO @temp (Extract)
SELECT ''EXEC( ''''USE ' + @DestDatabase + '; IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'''''''''' + name + '''''''''')IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'''''''''' + name + '''''''''') DROP USER [''  + name + '']''''); ''
FROM sys.sysusers WHERE islogin = 1 AND hasdbaccess = 1 AND name NOT IN (''dbo'')
 
 
 
INSERT INTO @temp (Extract) 
SELECT ''EXEC( ''''USE ' + @DestDatabase + '; IF NOT EXISTS 
(SELECT * FROM sys.database_principals WHERE name = N'''''''''' + dp.name + '''''''''') 
CREATE USER ['' + dp.name + ''] FOR LOGIN ['' + sp.name + '']''''); ''
FROM sys.server_principals sp 
JOIN sys.database_principals dp ON (sp.sid = dp.sid) 
AND dp.name NOT IN (''dbo'')
 
INSERT INTO @temp (Extract) 
SELECT ''EXEC( ''''USE ' + @DestDatabase + 
            '; IF NOT EXISTS
 (SELECT * FROM sys.database_principals WHERE name = N'''''''''' + dp.name + '''''''''')
  CREATE USER ['' + dp.name + ''] WITHOUT LOGIN '''');  ''
FROM sys.database_principals dp left 
JOIN sys.server_principals sp ON (sp.sid = dp.sid) 
where dp.principal_id between 5 and 16383
 
INSERT INTO @temp (Extract) 
SELECT ''EXEC( ''''USE ' + @DestDatabase + '; EXEC sp_addrolemember '''''''''' + User_Name([groupuid]) + '''''''''', '''''''''' + User_Name([memberuid]) + ''''''''''''''); ''
FROM sys.sysmembers WHERE User_Name([memberuid]) NOT IN (''dbo'')
 
INSERT INTO @temp (Extract) 
SELECT ''EXEC( ''''USE ' + @DestDatabase + 
            '; ''
 + CASE [a].[state_desc] WHEN ''GRANT_WITH_GRANT_OPTION'' THEN ''GRANT '' ELSE [a].[state_desc]  END
 + '' '' 
 + [a].[permission_name] + CASE class WHEN 1 THEN '' ON ['' 
 + [c].[name] 
 + ''].[''
 + Object_Name([a].[major_id]) + ''] '' ELSE '''' END + '' TO ['' 
 + User_Name([a].[grantee_principal_id]) 
 + ''] '' + CASE [a].[state_desc] WHEN ''GRANT_WITH_GRANT_OPTION'' THEN '' WITH GRANT OPTION'' ELSE '''' END 
 + ''''''); '' COLLATE Latin1_General_CI_AS AS [SQL]
FROM sys.database_permissions a 
 inner join [sys].[all_objects] b 
  ON [a].[major_id] = [b].[object_id]
 inner join [sys].[schemas] c
  ON [b].[schema_id] = [c].[schema_id]
 
SELECT Extract AS [Extract] FROM @temp
GO
'
            )
ELSE
    SELECT '--NO'
GO
 
 
