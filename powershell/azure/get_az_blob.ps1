$LogTime = Get-Date -Format "yyyy-MM-dd"
$Days = 31
$RententionDate=(Get-Date).AddDays(- $Days)
$storage_account = '##########'
$storage_account_key = '##########'
$storage_context = New-AzureStorageContext -StorageAccountName $storage_account -StorageAccountKey $storage_account_key -ErrorAction Stop -Verbose
$contaninerlist = Get-AzureStorageContainer -Context $storage_context -Verbose | Where-Object { $_.Name -in '##########'} | Select-Object name
$contaninerlist | ForEach-Object {
  $containername = $_.Name
  $filelist = Get-AzureStorageBlob -Context $storage_context -Container $containername -Blob "*.trn" | Where-Object LastModified -LT $RententionDate | Select-Object *
  }

  $filelist | Out-GridView
