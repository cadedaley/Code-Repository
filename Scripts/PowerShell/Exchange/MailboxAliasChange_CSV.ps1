### Changes Aliases for users imported from a CSV based on their Mailbox GUID ###
### New Aliases are set based on the $newEmail which takes everything before @ symbol and appends it to the new e-mail alias ###

### Run in Exchange Management Shell! ###

#Define the path to your CSV file
$csvPath = "C:\Temp\AliasChange\AliasChangeList.csv"
$users = Import-Csv -Path $csvPath

$logFilePath = "C:\Temp\AliasChange\ProxyAddressUpdate.log"

foreach ($user in $users) {
    #Constructs $newEmail based on current e-mail address
    $email    = $user.UPN
    $username = ($email -split "@")[0]
    $newEmail = "$username@ACME.edu"

    # Track whether we've succeeded
    $success = $false

    # Collect error messages so we can log them if the operation fails
    $errorMessages = @()
    $Total = 0
    $TotalSeconds = 0

    if (!($user.MailboxGuid -match "Not Found")) {
        try {
            $start = Get-Date

            Set-RemoteMailbox -Identity $user.MailboxGuid -EmailAddresses @{add=$newEmail} -ErrorAction Stop

            $Total++
            $finish = (Get-Date)
            $elapsed = ($finish - $start).Seconds
            $TotalSeconds += $elapsed
            $Average = [math]::floor($TotalSeconds / $Total)

            Write-Host "Added $newEmail as a proxy address for $email in $elapsed seconds"
            $success = $true
        }
        catch {
            # Capture the error message
            $errorMessages += "Failed to add $newEmail to $email. Error: $($_.Exception.Message)"
        }

        # Log error if not successful
        if (-not $success) {
            $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            $logEntryBase = "$timestamp : ERROR adding $newEmail to $email."

            Write-Host $logEntryBase -ForegroundColor Red

            foreach ($msg in $errorMessages) {
                Write-Host "    $msg" -ForegroundColor Red
            }

            Add-Content -Path $logFilePath -Value $logEntryBase
            foreach ($msg in $errorMessages) {
                Add-Content -Path $logFilePath -Value "    $msg"
            }
        }
    }
}