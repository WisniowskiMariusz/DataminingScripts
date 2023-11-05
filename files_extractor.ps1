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

Function ExtractAndLog {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination
  )
  if (-not (Test-Path $Source)) {
    WriteLog("$Source does not exist so cannot be extracted")
    }
  else {
    $argList = '"x" "{0}" "{1}"' -f $Source, $Destination #"-y"
    Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait
    WriteLog("Content of $Source has been extracted to $Destination location")
  }  
}

Function ExtractAndArchive {
  param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$Archive
  ) 
ExtractAndLog -Source "$Source\*.rar" -Destination $Destination
foreach ($file in (Get-ChildItem -Path $Source -Name))
{
  MoveAndLog -Source "$Source\$file" -Destination $Archive
}
}

WriteLog("******************************************************************************************")
WriteLog("Script has started...")

$this_month = (Get-Date).toString('yyyy_MM')
$last_month = (Get-Date).AddMonths(-1).toString('yyyy_MM')
if (Test-Path "$extract_output_basepath/After/$this_month") {
  $Destination = "$extract_output_basepath/After/$this_month"
  }
else {
  $Destination = "$extract_output_basepath/After/$last_month"
}

# Looking for folders with files to extract
$to_extract = (Get-ChildItem -Path $extract_source_path -Name).Where({$_ -match '^[0-9]{4}(_[0-9]{2}){2}$'})
foreach ($folder in $to_extract)
{
  CreateIfNotExist("$extract_source_path/Archive/$folder")
  ExtractAndArchive -Source "$extract_source_path\$folder" -Destination "$Destination" -Archive "$extract_output_basepath/Archive/$folder"  
  if (-not ($folder -eq ($to_extract | Select-Object -Last 1))){    
    Remove-Item "$extract_source_path/$folder"
  }
}

WriteLog("Script completed.")
WriteLog("******************************************************************************************")
Pause

Stop-Transcript

    

    
                