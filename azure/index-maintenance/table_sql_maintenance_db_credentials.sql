CREATE MASTER KEY ENCRYPTION BY PASSWORD = '';
GO

CREATE CERTIFICATE azure_maintenance_cert  
   WITH SUBJECT = 'azure maintenance credential certificate  ';  
GO  

CREATE SYMMETRIC KEY azure_maintenance_Key
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE azure_maintenance_cert ;  
GO  

//DROP TABLE [sqldba].[sql_maintenance_db_credentials] 

IF NOT EXISTS (SELECT  schema_name FROM    information_schema.schemata WHERE   schema_name = 'sqldba' ) 
BEGIN
	EXEC dbo.sp_executesql @command= N'CREATE SCHEMA [sqldba]'
END
												   
   

CREATE TABLE [sqldba].[sql_maintenance_db_credentials] (
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[customer] NVARCHAR(max) NOT NULL,
	[login] varbinary(max) NOT NULL,
	[password] varbinary(max) NOT NULL,
	[tenant] varbinary(max) NOT NULL,
	[created] datetime DEFAULT getdate(),
	[comments] NVARCHAR(max) NULL
	)

-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY azure_maintenance_Key 
   DECRYPTION BY CERTIFICATE azure_maintenance_cert;  


INSERT INTO [sqldba].[sql_maintenance_db_credentials]
           ([customer]
           ,[login]
           ,[password]
           ,[tenant]
           ,[created]
           ,[comments])
     VALUES
           ('DCCUST'
		   , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar(max),'') ) 
           , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar(max),'') ) 
 	       , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar(max),'') ) 
           ,getdate()
           ,'NA')

CLOSE SYMMETRIC KEY azure_maintenance_Key;
GO

OPEN SYMMETRIC KEY azure_maintenance_Key 
   DECRYPTION BY CERTIFICATE azure_maintenance_cert;  



SELECT [ID]
      ,[customer]
	  ,CONVERT(nvarchar(max),DecryptByKey([login])) [login]
	  ,CONVERT(nvarchar(max),DecryptByKey([password])) [password]
	  ,CONVERT(nvarchar(max),DecryptByKey([tenant])) [tenant]
      ,[created]
      ,[comments]
  FROM [sqldba].[sql_maintenance_db_credentials]

CLOSE SYMMETRIC KEY azure_maintenance_Key;
GO

OPEN SYMMETRIC KEY azure_maintenance_Key DECRYPTION BY CERTIFICATE azure_maintenance_cert;

SELECT vsmp.[customer] 
	,[Server_Name]
	,[Databases]
	,[Script]
	,CONVERT(nvarchar(max), DecryptByKey([login])) [login]
	,CONVERT(nvarchar(max), DecryptByKey([password])) [password]
	,CONVERT(nvarchar(max), DecryptByKey([tenant])) [tenant]
FROM [sqldba].[vw_sql_maintenance_parameters] vsmp
LEFT JOIN [sqldba].[sql_maintenance_db_credentials] smdc ON vsmp.[customer] = smdc.[customer];

CLOSE SYMMETRIC KEY azure_maintenance_Key;
