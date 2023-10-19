# Get environment from config file
Foreach ($i in $(Get-Content archivizer.conf)){
  Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
}

function WriteLog {
Param ([string]$LogString)
$Stamp = (Get-Date).toString($DateFormat)
$LogMessage = "$Stamp $LogString"
Write-Host $LogMessage
Add-content $logfile -value $LogMessage
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

# Looking for temporary folders
$temporary_all = Get-ChildItem -Path $FromFolderPath -Name -Filter '*Tymczasowy*'

# Looking for empty temporary folders
$temporary_empty = $temporary_all.Where({Test-DirectoryIsEmpty -Path "$FromFolderPath\$_"})

# Path to first empty temporary folder
$destination = "$FromFolderPath\$($temporary_empty[0])"

# Looking for folders which should be archivized and sent
$folders_list = @(Get-ChildItem -Path $FromFolderPath -Name -Filter '*_*_*')
$dates = $null
foreach ($foldername in $folders_list)
{
  $dates += @([Datetime]::ParseExact($foldername, 'yyyy_MM_dd', $null))  
}
for($i=1; $i -lt $dates.Length; $i++)
{  
  if (($dates[$i] - $dates[$i-1]).ToString().Split(".")[0] -gt 1)
    {
      $first_to_move = $folders_list[$i]    
    }  
}
if ($null -eq $first_to_move) {
  $first_to_move = $folders_list[0]
}

$folders_to_move = $folders_list.Where({$_ -eq $first_to_move}, 'SkipUntil')

# Moving folders which should be archivized and sent
foreach ($folder in $folders_to_move) {    
    Move-Item -LiteralPath "$FromFolderPath\$folder" -Destination $destination | Out-Null
  }

WriteLog([string]($folders_to_move.Count) + " new folders has been moved to $destination")

# Generate RAR archive with folders which should be archivized and sent
$argList = @("a",  "-r", "-ep1", "$destination\$($temporary_empty[0])@$PcName.rar" ,"$destination\*.*")
Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait
WriteLog([string]($folders_to_move.Count) + " new folders has been archivzed to $destination\$($temporary_empty[0])@$PcName.rar file.")

if ($temporary_empty.Count -in 1, 3) {
  # Looking for new and old temporary folders
  $temporary_new = $temporary_all.Where({Test-Path -Path "$FromFolderPath\$_\$_@$PcName.rar"})
  $temporary_old = $temporary_all.Where({($_ -notin $temporary_new) -and (-Not (Test-DirectoryIsEmpty -Path "$FromFolderPath\$_"))})
  # Moving and merging folders from temporary folders with was sent last time with those from main path
  foreach ($folder in $temporary_old) {
    Merge -Source "$FromFolderPath\$folder" -Destination $FromFolderPath
  }
  WriteLog([string]($temporary_old.Count) + " old folders has been merged back with $FromFolderPath")

  # Moving RAR archives to destiantion
  foreach ($folder in $temporary_new) {
    Move-Item -LiteralPath "$FromFolderPath\$folder\$folder@$PcName.rar" -Destination $ToFolderPath
  }
  WriteLog([string]($temporary_new.Count) + " rar files has been moved to destination folder:  $ToFolderPath")
}

# Clearing $dates and $first_to_move variable
$dates = $null
$first_to_move = $null

WriteLog("Script completed.")
WriteLog("******************************************************************************************")