SELECT DISTINCT CAT.[Path]
       ,'Get-RsSubscription -ReportServerUri "https://DBATools/Reportserver" -RsItem "' + CAT.[Path] +'" | Export-RsSubscriptionXml "C:\RSScripter\' + replace(CAT.[Path], '/', '') + '.xml"' [Export Report Sub XML]
       ,'Import-RsSubscriptionXml -ReportServerUri "https://DBATools_New/Reportserver" "C:\RSScripter\' + replace(CAT.[Path], '/', '') +'.xml" | Copy-RsSubscription -ReportServerUri "https://DBATools_New/Reportserver" -Rsitem "' +CAT.[Path]+'"' +' -ErrorAction SilentlyContinue -Verbose'
       [Import Report Sub XML]
FROM dbo.CATALOG AS cat
INNER JOIN dbo.Subscriptions AS sub
       ON CAT.ItemID = sub.Report_OID
INNER JOIN dbo.ReportSchedule AS res
       ON CAT.ItemID = res.ReportID
              AND sub.SubscriptionID = res.SubscriptionID
INNER JOIN msdb.dbo.sysjobs AS job
       ON CAST(res.ScheduleID AS VARCHAR(36)) = job.[name]
INNER JOIN msdb.dbo.sysjobschedules AS sch
       ON job.job_id = sch.job_id
INNER JOIN dbo.Users U
       ON U.UserID = sub.OwnerID
WHERE CAT.[Path] LIKE '/CMDHB Reports%'
--and sub.LastStatus !='The subscription contains parameter values that are not valid.'


