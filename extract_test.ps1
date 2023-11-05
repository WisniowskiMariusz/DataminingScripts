
$test = "D:\Test data\*.rar"
$arguments = '"x" "{0}" "D:\Output" "-y"' -f $test
Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $arguments -NoNewWindow -Wait
Pause