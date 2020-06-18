CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'xxxxxxxxxxxxxxxx';
GO

CREATE CERTIFICATE azure_maintenance_cert  
   WITH SUBJECT = 'azure maintenance credential certificate  ';  
GO  

CREATE SYMMETRIC KEY azure_maintenance_Key
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE azure_maintenance_cert ;  
GO  

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
           ('XXXX'
		   , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar,'xxxxxxxxxxxxxxxx') ) 
           , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar,'xxxxxxxxxxxxxxxx') ) 
 	       , EncryptByKey( Key_GUID('azure_maintenance_Key'), CONVERT(nvarchar,'xxxxxxxxxxxxxxxx') ) 
           ,getdate()
           ,'NA')

CLOSE SYMMETRIC KEY azure_maintenance_Key;
GO

OPEN SYMMETRIC KEY azure_maintenance_Key 
   DECRYPTION BY CERTIFICATE azure_maintenance_cert;  


SELECT [ID]
      ,[customer]
	  ,CONVERT(nvarchar,DecryptByKey([login])) [login]
	  ,CONVERT(nvarchar,DecryptByKey([password])) [password]
	  ,CONVERT(nvarchar,DecryptByKey([tenant])) [tenant]
      ,[created]
      ,[comments]
  FROM [sqldba].[sql_maintenance_db_credentials]


CLOSE SYMMETRIC KEY azure_maintenance_Key;


	