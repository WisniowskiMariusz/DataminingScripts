# Get environment from config file
$configfile = (Split-Path $MyInvocation.MyCommand.Path -Parent) + '\archivizer.conf'

Foreach ($i in $(Get-Content $configfile -Encoding "UTF8")){
    Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
}

Start-Transcript -Path $transcriptfile -Append
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
Function Test-DirectoryIsEmpty {
  param ([Parameter(Mandatory=$true)][string]$Path)
  Return(-Not(Test-Path -Path "$Path\*"))
}

Get-ChildItem "$FromFolderPath\Temporary"