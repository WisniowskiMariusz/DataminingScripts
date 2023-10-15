
#Set-ExecutionPolicy Unrestricted
$fromFolderPath = $args[0][0]
$toFolderPath = $args[0][1]
$toFilename = ""

if ($fromFolderPath.Split("\")[-1] -eq "")
{
    $toFilename = $fromFolderPath.Split("\")[-2]
    $fromFolderPath = $fromFolderPath.SubString(0, ($fromFolderPath.length-1))
}
else
{
    $toFilename = $fromFolderPath.Split("\")[-1]
}

$toFilePath = $($toFolderPath+"\"+$toFilename+".rar")

#Keep backup if archiving fails
try
{
    move $toFilePath $($toFilePath+".old" )
}
catch
{
    echo "No Backup Found"
}

#Generate RAR archive
$argList = @("a",  "-r", $destination)

Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait

#Remove Backup
$toFilePathOld = ($toFilePath)+".old"
del $toFilePathOld
