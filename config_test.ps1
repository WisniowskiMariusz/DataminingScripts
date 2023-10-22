Start-Transcript -Path 'C:\log\transcript.txt'

function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString($DateFormat)
$LogMessage = "$Stamp $LogString"
Switch ($logoption){
    {$_ -in ("Both", "Console")} {Write-Host $LogMessage}
    {$_ -in ("Both", "File")}{Add-content $logfile -value $LogMessage}
    }
}

$configfile = (Split-Path $MyInvocation.MyCommand.Path -Parent) + '\archivizer.conf'

Foreach ($i in $(Get-Content $configfile -Encoding "UTF8")){
    Write-Host($i.split("=",2)[1])
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
}

WriteLog("******************************************************************************************")
WriteLog($DateFormat) 
WriteLog($logfile) 
WriteLog($FromFolderPath) 
WriteLog($ToFolderPath) 
WriteLog($PcName) 
WriteLog("******************************************************************************************")

$test = Get-ChildItem -Path "G:\" -Name
$test = Join-Path -Path "G:" -ChildPath $test[1]
Write-Host $test
WriteLog($test)
Test-Path $test

Stop-Transcript