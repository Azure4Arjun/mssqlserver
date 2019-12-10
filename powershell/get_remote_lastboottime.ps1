$servers= Get-Content "C:\SQLDBA\server.txt"

$ps_version = ForEach-Object {

Invoke-Command  -Computername $servers -Scriptblock {Get-WmiObject win32_operatingsystem | select csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}} -Verbose
}

$ps_version | Out-GridView
