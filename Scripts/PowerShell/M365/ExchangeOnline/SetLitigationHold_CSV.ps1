### Sets a Litigation Hold for Users based on the UPN ###
### Results Displayed in Terminal ###

Connect-ExchangeOnline

#Import the CSV file
$users = Import-Csv -Path $csvFilePath

#Check if the file contains the required column
if (-not ($users | Get-Member -Name "UPN")) {
    Write-Error "The CSV file does not contain the 'UPN' column."
    return
}

foreach($user in $user){ 
    Write-Progress -Activity "Placing litigation hold to -$user..." 
    Set-Mailbox -Identity $User.User -LitigationHoldEnabled $True 

If($?) { 
    Write-Host Placed Litigation Hold Successfully to $User.user -ForegroundColor Green 
    }

    Else { 
    Write-Host Error occurred while placing litigation hold to $User.user -ForegroundColor Red 
    } 
}

#Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false