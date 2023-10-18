# Set paths
$fromFolderPath = "D:\Testdata\h2n"

# Looking for empty temporary folders
$tymczasowe_list = Get-ChildItem -Path $fromFolderPath -Name -Filter '*Tymczasowy*'
$tymczasowe_empty = $tymczasowe_list.Where({Test-DirectoryIsEmpty -Path "$fromFolderPath\$_"})
$tymczasowe_notempty = $tymczasowe_list.Where({$_ -notin $tymczasowe_empty})
$destination = "$fromFolderPath\$($tymczasowe_empty[0])"
$destination
$tymczasowe_notempty

# Looking for folders to move
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
$folders_to_move = $folders_list.Where({$_ -eq $first_to_move}, 'SkipUntil')
$first_to_move

foreach ($folder in $folders_to_move)
{    
    Move-Item -LiteralPath "$fromFolderPath\$folder" -Destination $destination
}
$dates = $null

foreach ($folder in $tymczasowe_notempty)
{
    "-------"
    $to_move = Get-ChildItem -Path "$fromFolderPath\$folder" | Move-Item -Destination $fromFolderPath -Force
    $to_move
    "-------"
}