--This will set the date time stamp to pass onto the Stored Proc for 72 hours from the current date when it runs
--The stored proc will recursively delete all TRN files from the parent level specified all the way down
declare @DeleteDate nvarchar(50)
declare @DeleteDateTime datetime
set @DeleteDateTime = DateAdd(DD, -4, GetDate())
set @DeleteDate = (Select Replace(Convert(nvarchar, @DeleteDateTime, 111), '/', '-') + 'T' + Convert(nvarchar, @DeleteDateTime, 108))
--print @deletedate
--5th argument below "0 - don't delete recursively (default)" and  "1 - delete files in sub directories"
EXECUTE master.dbo.xp_delete_file 0,N'\\fileshare\tlog\',N'trn', @DeleteDate,1
