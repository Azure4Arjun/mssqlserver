$servers= Get-Content "C:\SQLDBA\server.txt"

$ps_Scriptblock = ForEach-Object {

Invoke-Command  -Computername $servers -Scriptblock {Get-WmiObject win32_operatingsystem | select csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}} -Verbose
}

$ps_Scriptblock | Out-GridView
