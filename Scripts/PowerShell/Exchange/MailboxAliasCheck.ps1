### Checks Aliases for the listed $Domain for Users and then exports the results to a CSV ###
### CSV Reports Display Name, Mailbox GUID, Number of Aliases with $Domain, and the Aliases themselves ###

### Useful for finding potential E-mail Collisions ###
### Run in Exchange Management Shell! ###

# Specify the domain you want to search for.
$Domain = '@ACME.org'

# Array to hold our results.
$Results = @()

# Retrieve all Remote Mailboxes (unlimited).
Get-RemoteMailbox -ResultSize Unlimited | ForEach-Object {
    $Mailbox = $_

    # Filter out any addresses that end with the specified domain.
    $MatchedAliases = $Mailbox.EmailAddresses | Where-Object {
        $_ -match "SMTP:.*$($Domain)$"
    }

    # Remove smtp:/SMTP: portion from each alias.
    $CleanedAliases = $MatchedAliases -replace '^(smtp|SMTP):', ''

    if ($CleanedAliases.Count -gt 0) {
        # Convert the array to a string for exporting.
        $AliasString = $CleanedAliases -join '; '

        # Add the mailbox's details to our result array.
        $Results += [PSCustomObject]@{
            DisplayName = $Mailbox.DisplayName
            MailboxGUID = $Mailbox.Guid
            AliasCount  = $CleanedAliases.Count
            Aliases     = $AliasString
        }
    }
}

# Export the results to a CSV file.
$CsvPath = 'C:\Temp\MailboxAliases.csv'
$Results | Export-Csv -Path $CsvPath -NoTypeInformation

Write-Host "Results exported to: $CsvPath"