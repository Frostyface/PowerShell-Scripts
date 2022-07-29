<#
Author: Michael Majercin 
Date: 04/25/2022
Usage: Script will delete all files and folders older than 30 days in the directory contained in the Folder variable

Allows local scripts to run regardless of signature, and requires trusted digital signatures only for remote scripts.
> Set-ExecutionPolicy RemoteSigned

Last update: April, 25, 2022
#>

#Folder variable contains absolute path to directory you want to clean up 
$Folder = "C:\Users\mmajercin\Documents\Junk4"
$limit = (Get-Date).AddDays(-30)
$log_path = "C:\Users\mmajercin\Documents\log.txt"
$log_count = 0

#Create Log File if does not exist 
#"Count of files deleted by date:" | Out-File -FilePath $log_path

#Delete files older than 30 days 
Get-ChildItem -Path $Folder -Recurse | Where-Object {($_.CreationTime -lt $limit)} |
ForEach-Object {
   $_ | Remove-Item -Force
   $log_count++
}
# X files deleted on "todays date" entry sent to log file 
[string]$log_count + " Files deleted on " + ($limit.AddDays(30)) | Out-File -FilePath $log_path -Append

