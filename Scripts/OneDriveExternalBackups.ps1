#Written by Cade Daley

#If you get the location wrong when prompted, You can go to H drive and look for "backuplocation.txt" and delete it.
#You will not be prompted again unless file is deleted.

# If destination path is found, the script runs as normal
$Check = Test-Path  H:\backuplocation.txt
If ($Check  -eq 'True')  {
    $UserNameInfo = $ENV:USERNAME 
    $DestinationFolder= Get-Content H:\backuplocation.txt | Select -First 1
    robocopy "C:\Users\${usernameinfo}\OneDrive - Georg Fischer" "$DestinationFolder\Backups" /e /v /COPY:DATSO /log:H:\backup_log.txt
}
# If it is not found, user is prompted for path to copy files to and a scheduled task is set.
    ElseIf ($Check  -ne 'True')  {
        $UserNameInfo = $ENV:USERNAME 
        Read-Host -Prompt "Enter the Destination Drive to store your Backup e.g. D:\" | Out-File -FilePath H:\backuplocation.txt

        $DestinationFolder= Get-Content H:\backuplocation.txt | Select -First 1
        robocopy "C:\Users\${usernameinfo}\OneDrive - Georg Fischer" "$DestinationFolder\Backups" /e /v /COPY:DATSO /log:H:\backup_log.txt
        
        # Creates scheduled task as defined times
        $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -file "H:\OneDriveExternalBackups.ps1" -WindowStyle Hidden'
        $trigger = New-ScheduledTaskTrigger -Once -At $dateTime -RepetitionInterval (New-TimeSpan -Hours 2)
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "OneDrive Backup Script" -Description "Backup Script for Copying Files from OneDrive to an External Drive"

        # Get the access control list for the folder
        $acl = Get-Acl $DestinationFolder

        # Create a new access control entry for the current user
        $ace = New-Object System.Security.AccessControl.FileSystemAccessRule($UserNameInfo,"FullControl","Allow")

        # Add the access control entry to the access control list
        $acl.AddAccessRule($ace)

        # Set the access control list for the folder
        Set-Acl $DestinationFolder $acl
    }