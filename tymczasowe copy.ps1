Function Test-DirectoryIsEmpty {
  param (
      [Parameter(Mandatory=$true)][string]$Path
  )
  Return(-Not(Test-Path -Path "$Path\*"))
}

# Set main path
$fromFolderPath = "D:\Testdata\h2n"

# Looking for temporary folders
$tymczasowe_list = Get-ChildItem -Path $fromFolderPath -Name -Filter '*Tymczasowy*'

# Looking for empty temporary folders
$tymczasowe_empty = $tymczasowe_list.Where({Test-DirectoryIsEmpty -Path "$fromFolderPath\$_"})

$temporary_new = $tymczasowe_list.Where({Test-Path -Path "$fromFolderPath\$_\$_.rar"})
$temporary_old = $tymczasowe_list.Where({($_ -notin $tymczasowe_empty ) -and ($_ -notin $temporary_new )})

# Looking for folders which should be archivized and sent
$folders_list = @(Get-ChildItem -Path $fromFolderPath -Name -Filter '*_*_*')
foreach ($foldername in $folders_list)
{
  $dates += @([Datetime]::ParseExact($foldername, 'yyyy_MM_dd', $null))  
}
for($i=1; $i -lt $dates.Length; $i++)
{  
  if (($dates[$i] - $dates[$i-1]).ToString()[0].ToString() -gt 1)
    {
      $first_to_move = $folders_list[$i]    
    }  
}
if ($null -eq $first_to_move) {
  $first_to_move = $folders_list[0]
}

$folders_to_move = $folders_list.Where({$_ -eq $first_to_move}, 'SkipUntil')

Write-Host "First to move: " $first_to_move
Write-Host "Folders to move: " $folders_to_move

foreach ($folder in $tymczasowe_empty) {
  $destination += @("$fromFolderPath\$folder")  
}

foreach ($folder in $destination) {
  Write-Host $folder  
}

$temporary_new = $temporary_all.Where({(Test-Path -Path "$fromFolderPath\$_\$_.rar") -or ($_ -in $temporary_empty)})
$temporary_old = $temporary_all.Where({$_ -notin $temporary_new})

$destination = $null

Write-Host 'Empty :'$tymczasowe_empty
Write-Host 'Count :'$tymczasowe_empty.Count
Write-Host 'Old :'$temporary_old
Write-Host 'New :' $temporary_new

$dates = $null