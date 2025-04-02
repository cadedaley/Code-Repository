### Iterates through users in a CSV file based on the UPN Column and checks Litigation Hold Status ###
### Results Exported to a CSV ###

Connect-ExchangeOnline

#Path to the CSV file
$csvFilePath = "C:\Temp\LitHoldCheck.csv"

#Import the CSV file
$users = Import-Csv -Path $csvFilePath

#Check if the file contains the required column
if (-not ($users | Get-Member -Name "UPN")) {
    Write-Error "The CSV file does not contain the 'UPN' column."
    return
}

#Output file to store results
$outputFilePath = "C:\Temp\LitigationHoldResults.csv"
$results = @()

#Loop through each user and check litigation hold status
foreach ($user in $users) {
    $upn = $user.UPN
    
    #Try to get the mailbox
    try {
        $mailbox = Get-Mailbox -Identity $upn -ErrorAction Stop
        
        #Check litigation hold status
        $litigationHoldEnabled = $mailbox.LitigationHoldEnabled
        
        #Add the result to the results array
        $results += [PSCustomObject]@{
            UserPrincipalName = $upn
            LitigationHoldEnabled = $litigationHoldEnabled
        }

    } catch {
        Write-Warning "Could not retrieve mailbox for user: $upn. Error: $_"
        $results += [PSCustomObject]@{
            UserPrincipalName = $upn
            LitigationHoldEnabled = "Error: $_.Exception.Message"
        }
    }
}

#Export results to a CSV file
$results | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8

Write-Host "Results have been saved to $outputFilePath"

#Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false