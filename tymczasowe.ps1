Function Test-DirectoryIsEmpty {
  param (
      [Parameter(Mandatory=$true)][string]$Path
  )
  Return(-Not(Test-Path -Path "$Path\*"))
}

#Set paths
$fromFolderPath = "D:\Testdata\h2n"

$tymczasowe_list = Get-ChildItem -Path $fromFolderPath -Name -Filter '*Tymczasowy*'

foreach ($foldername in $tymczasowe_list)
{
  Write-Host $foldername" is "$(Test-DirectoryIsEmpty -Path "$fromFolderPath\$foldername")  
}

$folders_list = @(Get-ChildItem -Path $fromFolderPath -Name -Filter '*_*')

foreach ($foldername in $folders_list)
{
  $dates += @([Datetime]::ParseExact($foldername, 'yyyy_MM_dd', $null))  
}

for($i=0; $i -lt $dates.Length; $i++)
{
  Write-Host ($i, ". ", $folders_list[$i], " | ", $dates[$i]) 
}

for($i=1; $i -lt $dates.Length; $i++)
{  
  if (($dates[$i] - $dates[$i-1]).ToString()[0].ToString() -gt 1)
    {
      $first_to_copy = $folders_list[$i]
    }
  # Write-Host ($i, ". ", ($dates[$i] - $dates[$i-1]).ToString()[0] ) 
}

$to_copy = $folders_list.Where({$_ -eq $first_to_copy}, 'SkipUntil')

$to_copy


$empty = $tymczasowe_list.Where({Test-DirectoryIsEmpty -Path "$fromFolderPath\$_"})

foreach ($foldername in $empty)
{
  Write-Host "$foldername is empty"
}

$dates = $null