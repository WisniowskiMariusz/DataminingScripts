# Set main path
$fromFolderPath = "D:\Testdata\h2n"

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
$tymczasowe_list = Get-ChildItem -Path $fromFolderPath -Name -Filter '*Tymczasowy*'

# Looking for empty temporary folders
$tymczasowe_empty = $tymczasowe_list.Where({Test-DirectoryIsEmpty -Path "$fromFolderPath\$_"})

# Looking for not empty temporary folders
$tymczasowe_notempty = $tymczasowe_list.Where({$_ -notin $tymczasowe_empty})

# Merging all folders from temporary folders with those from main path
foreach ($folder in $tymczasowe_notempty) {
  Merge -Source "$fromFolderPath\$folder" -Destination $fromFolderPath
}