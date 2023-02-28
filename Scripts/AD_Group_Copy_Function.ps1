import-Module ActiveDirectory

#This Prompts the Administrator to enter the information located in the User Logon Name field
$copy = Read-host "Enter the i1B Number of the User you wish to Copy Groups From"
$paste = Read-host "Enter the i1B Number of the User you wish to Add Groups"

#This copys the users group from the 1st entry above and pastes those groups to the second entry entered
$CopyFromUser = Get-ADUser $copy -prop MemberOf
$CopyToUser = Get-ADUser $paste -prop MemberOf

$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser

Write-Host "Import Completed! Closing in 5 Seconds." -ForegroundColor Green
Write-Host "Please Re-Open the AD Window for the User to see Group Changes." -ForegroundColor Green

Sleep 5