# Get environment from config file
$currentpath = (Split-Path $MyInvocation.MyCommand.Path -Parent)

Foreach ($i in $(Get-Content "$currentpath\archivizer.conf" -Encoding "UTF8")){
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
Function Test-DirectoryIsEmpty {
  param ([Parameter(Mandatory=$true)][string]$Path)
  Return(-Not(Test-Path -Path "$Path\*"))
}
Function RunScript {
    param(
      [Parameter(Mandatory=$true)][string]$Path      
    )
    if (-not (Test-Path $Path)) {
      WriteLog("$Path does not exist so cannot be launched.")
      }
    else {
      $argList = @("$Path")
      Start-Process Powershell -ArgumentList $argList -NoNewWindow -Wait
      WriteLog("Script $Path has been launched...")
    }  
  }

$basepath = (Split-Path $MyInvocation.MyCommand.Path -Parent)
RunScript -Path "$basepath\test.ps1"