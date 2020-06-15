$wc = New-Object System.Net.WebClient
$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

Find-Module -Name "dbatools" -Repository "PSGallery"  -RequiredVersion 1.0.72 | Save-Module -Path "C:\temp\Modules\" -Verbose

#Import module on management server : Copy dbatools module to C:\Program Files\WindowsPowerShell\Modules\

Import-Module -name 'C:\Program Files\WindowsPowerShell\Modules\dbatools\1.0.72\dbatools.psd1'

#invoke bulk sql patch 

$user=  Get-Credential

Update-DbaInstance -ComputerName SQL1,SQL2,SQL3 -Path \\DBATools01\PatchRepo -Authentication Credssp -Credential $user -ExtractPath C:\temp -Restart -Verbose #-WhatIf 
