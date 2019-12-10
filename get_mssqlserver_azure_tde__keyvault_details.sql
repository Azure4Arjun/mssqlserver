##https://www.sqlshack.com/configure-tde-database-alwayson-using-azure-key-vault-sql-server-2016/##


SELECT 
	d.name, 
	dek.encryption_state
FROM
sys.dm_database_encryption_keys AS dek
JOIN sys.databases AS d
ON dek.database_id = d.database_id

select * from sys.configurations
where name like '%EKM%'

select * from sys.cryptographic_providers

select * from sys.credentials
where target_type='CRYPTOGRAPHIC PROVIDER'

select * from sys.asymmetric_keys
where provider_type='CRYPTOGRAPHIC PROVIDER'

select * from sys.server_principal_credentials spc
join sys.credentials sc on spc.credential_id= sc.credential_id
join sys.server_principals ssp on spc.principal_id=ssp.principal_id

SELECT sd.name
	,sd.is_encrypted
	,db_name(dek.database_id) TDE_DB_Name
	,dek.encryptor_thumbprint TDE_db_encryptor_thumbprint
	,spc.*
	--,ssp.*
	,ssp.name TDE_Login
	,ssp.sid TDE_Login_SID
	,ssp.type_desc TDE_Login_Type_DESC
	--,sc.*
	,sc.name TDE_Credential_Name
	,sc.credential_identity TDE_credential_identity
	,sc.target_type TDE_credential_target_type
	,sc.create_date TDE_credential_create_date
	,sc.modify_date TDE_credential_modify_date
	--,ak.*
	,ak.name asymmetric_keys_name
	,ak.thumbprint asymmetric_keys_thumbprint
	,ak.sid asymmetric_keys_sid
FROM sys.server_principal_credentials spc
JOIN sys.credentials sc ON spc.credential_id = sc.credential_id
JOIN sys.server_principals ssp ON spc.principal_id = ssp.principal_id
JOIN sys.asymmetric_keys ak ON ak.sid = ssp.sid
JOIN sys.dm_database_encryption_keys dek ON dek.encryptor_thumbprint = ak.thumbprint
RIGHT JOIN sys.databases sd ON sd.database_id = dek.database_id
where db_name(dek.database_id) is not null
ORDER BY dek.encryptor_thumbprint

SELECT DB_NAME(database_id) AS DatabaseName, encryption_state,
encryption_state_desc =
CASE encryption_state
         WHEN '0'  THEN  'No database encryption key present, no encryption'
         WHEN '1'  THEN  'Unencrypted'
         WHEN '2'  THEN  'Encryption in progress'
         WHEN '3'  THEN  'Encrypted'
         WHEN '4'  THEN  'Key change in progress'
         WHEN '5'  THEN  'Decryption in progress'
         WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
         ELSE 'No Status'
         END,
percent_complete,encryptor_thumbprint, encryptor_type  FROM sys.dm_database_encryption_keys

