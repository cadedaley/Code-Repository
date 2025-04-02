#This script takes UserIDs from a text file and then outputs the information into a CSV File.
#The following information is outputted: First Name, Last Name, Display Name, & Manager

Get-Content -Path C:\Temp\Users.txt |
    ForEach-Object {
        Get-Aduser -Identity $_ -Properties 'GivenName', 'Surname', 'DisplayName', 'Manager' |
        Select-Object `
            'GivenName',
            'Surname',
            'DisplayName',
            @{Name='Manager'; Expression={If ($_.Manager) {(Get-Aduser -Identity $_.Manager -Properties DisplayName).DisplayName} Else {''}}}
    } | Export-Csv -Path C:\Temp\UsersCompleted.csv -NoTypeIn
