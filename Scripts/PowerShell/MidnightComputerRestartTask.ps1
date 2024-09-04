# Simple script that adds a Scheduled Task to Restart the machine at midnight.

$action = New-ScheduledTaskAction -Execute '%SystemRoot%\system32\shutdown.exe' -Argument '/r /f /t 0'
$trigger = New-ScheduledTaskTrigger -Daily -At 12am

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Midnight Computer Restart" -Description "Restarts the Device every night at Midnight"
