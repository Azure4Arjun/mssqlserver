/*https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/file-object*/


USE master
GO

DECLARE @hr INT;
DECLARE @dt_LastModified DATETIME;
DECLARE @obj_file INT;
DECLARE @obj_file_system INT;
DECLARE @file_name VARCHAR(100) = '\\DBATools\DBATools.bak';

-- Create a FileSystemObject. Create this once for all subsequent file manipulation. Don't forget to destroy this object once you're done with file manipulation (cf cleanup)
EXEC @hr = sp_OACreate 'Scripting.FileSystemObject'
	,@obj_file_system OUTPUT;

IF @hr <> 0
	GOTO __cleanup;

-- Get a handle for the file. Don't forget to release the handle for each file you get a handle for (see cleanup). The return will be different from 0 if the file doesn't exist
EXEC @hr = sp_OAMethod @obj_file_system
	,'GetFile'
	,@obj_file OUTPUT
	,@file_name;

IF @hr <> 0
	GOTO __print_DateLastModified_date;

-- Retrieve the created date.
EXEC sp_OAGetProperty @obj_file
	,'DateLastModified'
	,@dt_LastModified OUTPUT;

__print_DateLastModified_date:

SELECT @dt_LastModified AS file_date;

__cleanup:

EXEC sp_OADestroy @obj_file_system;

EXEC sp_OADestroy @obj_file;
