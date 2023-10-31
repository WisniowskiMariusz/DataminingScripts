# Get environment from config file
$currentpath = (Split-Path $MyInvocation.MyCommand.Path -Parent)

Foreach ($i in $(Get-Content "$currentpath\archivizer.conf" -Encoding "UTF8")){
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
  if (Test-Path -Path "$Destination") {
    Get-ChildItem -Path $Source | ForEach-Object {
      if (Test-Path -Path "$Destination\$_") {
        if ((get-item "$Source\$_").PSIsContainer) {
          Merge -Source "$Source\$_" -Destination "$Destination\$_"
          Remove-Item "$Source\$_"
          }
        else {
          Move-Item -LiteralPath $Source\$_ -Destination $Destination -Force
          }
        }
      else {
        Move-Item -LiteralPath $Source\$_ -Destination $Destination -Force
        Writelog("$Source\$_ has been moved to $Destination.")
        }    
      }
    }
    else {
      Move-Item -LiteralPath $Source -Destination $Destination
      Writelog("$Source has been moved to $Destination.")        
    }
}

Function CreateIfNotExist {
  param ([Parameter(Mandatory=$true)][string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

Function MoveAndLog {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination
  )
  if (-not (Test-Path $Source)) {
    WriteLog("$Source does not exist so cannot be moved")
    }
  else {
    CreateIfNotExist($Destination)
    Move-Item -LiteralPath $Source -Destination $Destination -Force
    WriteLog("$Source folder has been moved to $Destination")      
  }  
}

Function RarAndLog {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination
  )
  if (-not (Test-Path $Source)) {
    WriteLog("$Source does not exist so cannot be archivized")
    }
  else {
    $argList = @("a",  "-r", "-ep1", "-ri14", "$Destination.rar" ,"$Source\*.*")
    Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait
    WriteLog("Content of $Source has been archivzed to $Destination.rar file.")
  }  
}

Function MoveRarMove {
  param(
    [Parameter(Mandatory=$true)][string]$Day,
    [Parameter(Mandatory=$true)][string]$Day_HH,
    [Parameter(Mandatory=$true)][string]$Destination
  )
MoveAndLog -Source "$FromFolderPath\$Day" -Destination $Destination
RarAndLog -Source $Destination -Destination $Destination\$PcName@$Day_HH
MoveAndLog -Source "$Destination\$PcName@$Day_HH.rar" -Destination "$ToFolderPath\$Day"
}


Function MergeBackAndLog {
  Get-ChildItem -Path "$FromFolderPath\Temporary\$Yesterday" | ForEach-Object {
    Merge -Source "$FromFolderPath\Temporary\$Yesterday\$_\$Yesterday" -Destination "$FromFolderPath\$Yesterday"
    WriteLog("$FromFolderPath\Temporary\$Yesterday\$_\$Yesterday has been successfully merged into $FromFolderPath.")
  }
}

WriteLog("******************************************************************************************")
WriteLog("Script has started...")

$Today = (Get-Date).toString('yyyy_MM_dd')
$Today_HH = (Get-Date).toString('yyyy_MM_dd_HH')
$Destination = "$FromFolderPath\Temporary\$Today\$Today_HH"

MoveRarMove -Day $Today -Day_HH $Today_HH -Destination $Destination

if ($(Get-Date).Hour -eq 0){  
  $Yesterday = (Get-Date).AddDays(-1).toString('yyyy_MM_dd')
  $Yesterday_HH = $Yesterday+"_24"
  MoveRarMove -Day $Yesterday -Day_HH $Yesterday_HH -Destination "$FromFolderPath\Temporary\$Yesterday\$Yesterday_HH"
  MergeBackAndLog
}

WriteLog("Script completed.")
WriteLog("******************************************************************************************")

Stop-Transcript