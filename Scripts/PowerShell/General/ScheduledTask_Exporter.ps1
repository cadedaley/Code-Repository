# EXPORTS Scheduled Tasks from Server Operating Systems
# Depending on the inputed parameters, this task can take a VERY long time to run!

# Gets the Date and Time of when the Task is run.
$Date = Get-Date -f "yyyy-MM-dd"
$Time = Get-Date -f "HH-mm-ss"

# Searches AD for any devices with a "Server" OS and a name that begins with US.
$Computers = (Get-ADComputer -Filter {operatingsystem -like "*server*" -and Name -like "US*"}).Name
$Computers > "C:\Temp\servers_$Date_$Time.txt"
$ErrorActionPreference = "SilentlyContinue"
$Report = @()

# Generates a Report for Each Computer and Stores it in a CSV. Combs C:\Windows\System32\Tasks for any Tasks.
foreach ($Computer in $Computers) {
    if (Test-Connection $Computer -Quiet -Count 1) {
        # Computer is online

        $path = "\\" + $Computer + "\c$\Windows\System32\Tasks"
        $tasks = Get-ChildItem -Path $path -File
        foreach ($task in $tasks) {

            #### TASK NAME FILTER ####
            # Skip tasks with "Optimize" or "User_Feed" in the task name
            if ($task.Name -like "*Optimize*" -or $task.Name -like "*User_Feed*") {
                continue
            }

            $Info = Get-ScheduledTask -CimSession $Computer -TaskName $task | Get-ScheduledTaskInfo | Select LastRunTime, LastTaskResult

            $Details = "" | Select-Object ComputerName, Task, User, Enabled, Application, LastRunTime, LastTaskResult
            $AbsolutePath = $task.Directory.FullName + "\" + $task.Name
            $TaskInfo = [xml](Get-Content $AbsolutePath)
            $user = $TaskInfo.task.principals.principal.userid

            #### TASK USERID Filter ####
            # Ignore tasks with specified users and tasks with no user
            if ($user -notin "SYSTEM", "S-1-5-18", "S-1-5-19", "NT Authority\System", "S-1-5-20" -and ![string]::IsNullOrEmpty($user)) {
                $Details.ComputerName = $Computer
                $Details.Task = $task.Name
                $Details.User = $user
                $Details.Enabled = $TaskInfo.task.settings.enabled
                $Details.Application = $TaskInfo.task.actions.exec.command
                $Details.LastRunTime = $Info.LastRunTime
                $Details.LastTaskResult = $Info.LastTaskResult
                $Details
                $Report += $Details
            }
        }
    }
    else {
        # Computer is offline
    }
}

# Sort the report by Author (User) field
$Report = $Report | Sort-Object User

# Outputs Report as a CSV to C:\Temp. Also includes the Date and Time of the Report.
$Report | Export-Csv "C:\Temp\Tasks_$Date_$Time.csv" -NoTypeInformation

# Define the path to the CSV file
$csvPath = "C:\Temp\Tasks_$Date_$Time.csv"

# Create a folder to store the XML files
$outputFolder = "C:\Temp\XMLFiles"
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null

# Import the CSV file
$tasks = Import-Csv $csvPath

# Group the tasks by computer name
$groupedTasks = $tasks | Group-Object -Property "ComputerName"

# Iterate over each group
foreach ($group in $groupedTasks) {
    $computerName = $group.Name
    $tasks = $group.Group

    # Create a separate folder for each server
    $serverFolder = Join-Path -Path $outputFolder -ChildPath $computerName
    New-Item -ItemType Directory -Force -Path $serverFolder | Out-Null

    # Convert each task to XML and save as a separate file
    foreach ($task in $tasks) {
        $xmlPath = Join-Path -Path $serverFolder -ChildPath "$($task.Task).xml"
        $task | Export-Clixml -Path $xmlPath
    }
}

Write-Host "XML files have been exported successfully."
