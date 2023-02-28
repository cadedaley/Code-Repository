#This script takes a list of e-mails from a .txt or .csv file and converts them into their UserID.
#If using a .csv file, ensure there is no header when executing the function the prevent errors.

#Path for Input File
Get-Content -Path C:\Temp\Example.txt | ForEach-Object {

    #Checks the Mail property of users and selects the SamAccountName and Mail address of the user associated
    Get-ADUser -Filter {mail -like $_} -properties mail | Select-Object SamAccountName,mail

    #Path for Export File
} | Export-csv -Path C:\Temp\Output.csv -NoTypeInformation