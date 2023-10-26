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

Function Merge {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination
  )
  Get-ChildItem -Path $Source | ForEach-Object {
    if (Test-Path -Path "$Destination\$_") {
      if ((get-item "$Source\$_").PSIsContainer) {
        Merge -Source "$Source\$_" -Destination "$Destination\$_"
        Remove-Item "$Source\$_"
        }
      else {
        Move-Item $Source\$_ -Destination $Destination -Force
        }
      }
    else {
      Move-Item $Source\$_ -Destination $Destination -Force
      }    
    }  
}

WriteLog("******************************************************************************************")
WriteLog("Script has started...")

WriteLog([int32]::MaxValue)

$BasePath = "$FromFolderPath\$((Get-Date).ToString("yyyy_MM_dd"))"

for ($stake=1; $stake -le 2; $stake++) {  
  for ($table=1; $table -le 3; $table++) { 
    if (-not (Test-Path "$BasePath\Stake$stake\Table$table")) {
      New-Item -ItemType Directory -Path "$BasePath\Stake$stake\Table$table" | Out-Null
    }
    for ($hand=1; $hand -le 10; $hand++) {
      Add-content "$BasePath\Stake$stake\Table$table\Handhistory$(Get-Random).txt" -value "Handhistory number $hand for table $table and stakes $stake."
    }
  }
}

WriteLog("Script completed.")
WriteLog("******************************************************************************************")

Stop-Transcript