### Resets All Users Delegates for the specified calender ###
### Should only be used if you believe there is a corrupted delegate permission ###

Remove-MailboxFolderPermission -Identity John.Doe@ACME.org:\Calendar\ -ResetDelegateUserCollection