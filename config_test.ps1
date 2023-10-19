Foreach ($i in $(Get-Content archivizer.conf)){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
}

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

WriteLog("******************************************************************************************")
WriteLog($DateFormat) 
WriteLog($logfile) 
WriteLog($FromFolderPath) 
WriteLog($ToFolderPath) 
WriteLog($PcName) 
WriteLog("******************************************************************************************")
