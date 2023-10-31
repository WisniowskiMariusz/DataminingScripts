#Write-Host [System.Text.Encoding]::UTF8.GetString(Split-Path -LiteralPath "G:\Użytkownicy\Gammix\Documents\Powershell\DataminingScripts\DataminingScripts" -Parent)

$string = "G:\UĹĽytkownicy"
$utf8EncodingObj = [System.Text.Encoding]::UTF8
$asciiEncodingObj = [System.Text.Encoding]::ASCII
$windows1250EncodingObj = [System.Text.Encoding]::windows-1250
$byteArray = $asciiEncodingObj.GetBytes($string)
$decodedByteArray = $utf8EncodingObj.GetString($byteArray)
Write-Host "Original String is: $string"
Write-Host "Byte Array is: $byteArray"
Write-Host "Decoded Byte Array is: $decodedByteArray"

Split-Path -Path "G:\Użytkownicy\Gammix\Documents\Powershell\DataminingScripts" -Parent

$string2 = Get-Content -Path "C:\log\pathtest.txt"

Write-Host $string2

Resolve-Path "G:\Użytkownicy\Gammix\Documents\Powershell\DataminingScripts"

Read-Host -Prompt "Press Enter to exit"

Write-Host "Użytkownik"



#Windows 1250