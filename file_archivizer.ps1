Start-Transcript -Path c:\log\myscript.log
# Set main path
$fromFolderPath = "D:\Testdata\h2n"
$ToFolderPath = "D:\Testdata\Output"
$PcName = "Ryzen2700x"

Function Test-DirectoryIsEmpty {
  param (
      [Parameter(Mandatory=$true)][string]$Path
  )
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

# Looking for temporary folders
$temporary_all = Get-ChildItem -Path $fromFolderPath -Name -Filter '*Tymczasowy*'

# Looking for empty temporary folders
$temporary_empty = $temporary_all.Where({Test-DirectoryIsEmpty -Path "$fromFolderPath\$_"})

# Path to first empty temporary folder
$destination = "$fromFolderPath\$($temporary_empty[0])"

# Looking for folders which should be archivized and sent
$folders_list = @(Get-ChildItem -Path $fromFolderPath -Name -Filter '*_*_*')
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
    Move-Item -LiteralPath "$fromFolderPath\$folder" -Destination $destination | Out-Null
  }

# Generate RAR archive with folders which should be archivized and sent
$argList = @("a",  "-r", "-ep1", "$destination\$($temporary_empty[0])@$PcName.rar" ,"$destination\*.*")
Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait

if ($temporary_empty.Count -in 1, 3) {
  # Looking for new and old temporary folders
  $temporary_new = $temporary_all.Where({(Test-Path -Path "$fromFolderPath\$_\$_@$PcName.rar") -or ($_ -in $temporary_empty)})
  $temporary_old = $temporary_all.Where({$_ -notin $temporary_new})
  # Moving and merging folders from temporary folders with was sent last time with those from main path
  foreach ($folder in $temporary_old) {
    Merge -Source "$fromFolderPath\$folder" -Destination $fromFolderPath
  }
  # Moving RAR archives to destiantion
  foreach ($folder in $temporary_new) {
    Move-Item -LiteralPath "$fromFolderPath\$folder\$folder@$PcName.rar" -Destination $ToFolderPath
  }
}

# Clearing $dates and $first_to_move variable
$dates = $null
$first_to_move = $null
Stop-Transcript