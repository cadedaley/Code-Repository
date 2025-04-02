#Pulls calendar permissions from calendars where the user is an Owner.

Write-Host
Write-Host
#Save User into a variable:
$User = "John.Doe@ACME.org" #Please modify; ensure it is using the quotation.

#Save all Calendars into a variable:
$Calendars = Get-MailboxFolderStatistics -Identity $User | Where-Object { $_.Identity -like "*Calendar*" } | Select-Object -ExpandProperty FolderPath
#Get all permissions per Calendar:
foreach ($Calendar in $Calendars) {
   $Calendar = $User + ':' + $Calendar
   $Calendar = ($Calendar -replace "/", "\")
   Write-Host "CHECKING " $Calendar -ForegroundColor Green
   Get-MailboxFolderPermission -Identity $Calendar | Where-Object { $_.AccessRights -notlike "*none*"} | FT Identity,User,AccessRights,SharingPermissionFlags,IsValid
   Write-Host
 }