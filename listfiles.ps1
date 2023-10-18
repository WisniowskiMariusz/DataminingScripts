#Set paths
$fromFolderPath = "G:\PokerkingHH\HHselling\Alex"

$folders_list = Get-ChildItem -Path $fromFolderPath -Name -Filter '*_*'

$i = 1
foreach ($foldername in $folders_list)
{
  Write-Host $i". "$foldername
  $i++
}

