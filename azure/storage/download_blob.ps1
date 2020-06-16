$LogTime = Get-Date -Format "yyyy-MM-dd"
$LogFile = 'C:\Log\' + "Download_Blob_" + $LogTime + ".log"

Start-Transcript $LogFile -Append
$Hour = 1
$BackupTime=(Get-Date).AddHours(- $Hour)
$containername=''
$storage_account = ''
$storage_account_key =''
$storage_context = New-AzureStorageContext -StorageAccountName $storage_account -StorageAccountKey $storage_account_key -ErrorAction Stop -Verbose
$contaninerlist = Get-AzureStorageContainer -Context $storage_context -Verbose | where-object name -eq $containername| Select-Object name
$contaninerlist | ForEach-Object {
  $containername = $_.Name
  $filelist = Get-AzureStorageBlob -Context $storage_context -Container $containername -Blob "*.*" | Where-Object LastModified -GT $BackupTime | Select-Object *
  foreach ($file in $filelist)
  {
    if ($file.Name -ne $null)
    {

      "Backups Since : " + $Hour + " hours - " + $BackupTime + " | " + $storage_account + "\" + $containername + "\" + $file.Name + " | Last Modified : " + $file.LastModified + " | Backup Start : " + $file.StartDate
        Get-AzureStorageBlobContent -Context $storage_context -Container $containername -Blob $file.Name -Destination  "\\SQLDBANET\blob\" #-WhatIf
      $flag = 1
    }
  }
  if ($flag -eq 0 -or $flag -eq $null) { Write-Host "No Recent backups:",$BackupTime}
}

Stop-Transcript
