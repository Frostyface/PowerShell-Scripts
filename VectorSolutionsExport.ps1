<#
Program name: Vector Solutions export
Description: Uploads files from Vector Solutions to Vector server 
Created By: Michael Majercin
Creation date: 6/13/2022
Modified date: 6/13/2022
Version# 1.0
Script log file: \\DATA2\BusinessApplications\VectorSolutions\Archive\VectorSolution_log.txt
#>

$CurrentDate = Get-Date
$Logfile = "\\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive\VectorSolutions_log.txt"
$winscplog = "\\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive\winscp_log.txt"
$Filename1 = "testfile.xlsx"
#$EmailTo = @('Workflow-ITDATA@susd.org')
$EmailTo = @('mmajercin@susd.org')
$Createtime = (Get-Item \\DATA2\c$\data2\BusinessApplications\VectorSolutions\TestFiles\$Filename1).LastWriteTime

$logoutput = "****************************`r`n"
$logoutput = $logoutput + $CurrentDate.ToString('MM-dd-yyyy hh:mm:ss tt') + "`r`n"

$Timediff = $CurrentDate - $Createtime 
$hours = [math]::Round($Timediff.totalhours,2)

$logoutput = $logoutput + "VectorSolutions Data files are $hours hours old.`r`n" 

if ($Timediff.totalhours -lt 2) 
{
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss')
$logoutput = $logoutput + "Zipping archive copy..`r`n"
Compress-Archive -Path \\DATA2\c$\data2\BusinessApplications\VectorSolutions\TestFiles\* -CompressionLevel Fastest -DestinationPath \\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive\$CurrentDate.zip -Force

$logoutput = $logoutput + "Starting WinSCP..`r`n"
c:\"Program Files (x86)"\WinSCP\winscp.com /command "option confirm off" "option batch abort" "open VectorSolutions" "put C:\DATA2\BusinessApplications\VectorSolutions\TestFiles\* /" "exit" >> $winscplog

$logoutput = $logoutput + "Completed WinSCP..`r`n"
$logoutput = $logoutput + "Checking log for errors..`r`n"
$filedata = Get-Content -Path $winscplog
$logoutput = $logoutput + $filedata + "`r`n"
Remove-Item $winscplog

if ($filedata -like "*error*")
{
$logoutput = $logoutput + "Vector Solutions ftp encountered errors. Please check and reprocess.`r`n"
$logoutput = $logoutput + "****************************`r`n"
Write-Output $logoutput >> $Logfile

#Send-MailMessage -To $EmailTo -From "workflow@susd.org"  -Subject "VectorSolutions ftp errored" -Body "$logoutput" -SmtpServer "mail.susd.org"
}
else
{
$Ftpcreatetime = (Get-Item "\\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive\$CurrentDate.zip").LastWriteTime

$logoutput = $logoutput + "No errors found..`r`n"
$logoutput = $logoutput + "VectorSolutions ftp processed at $Ftpcreatetime.`r`n"
$logoutput = $logoutput + "****************************`r`n"
Write-Output $logoutput >> $Logfile

#Send-MailMessage -To $EmailTo -From "workflow@susd.org"  -Subject "Vector Solutions ftp processed at $Ftpcreatetime" -Body "$logoutput" -SmtpServer "mail.susd.org"
}
}

else
{
$logoutput = $logoutput + "Data files are older than 2 hours. Ftp was not done.`r`n"
Write-Output $logoutput >> $Logfile

#Send-MailMessage -To $EmailTo -From "workflow@susd.org"  -Subject "Vector Solutions ftp not processed" -Body "$logoutput" -SmtpServer "mail.susd.org"
}

#Folder variable contains absolute path to directory you want to clean up 
$Folder = "\\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive"
$limit = (Get-Date).AddDays(-30)
$log_path = "\\DATA2\c$\data2\BusinessApplications\VectorSolutions\Archive\deleted_log.txt"
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

