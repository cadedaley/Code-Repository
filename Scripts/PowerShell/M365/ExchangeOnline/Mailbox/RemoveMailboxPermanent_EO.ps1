### Soft Deletes and then Hard Deletes a User ###
### Use with Caution! ###

Get-Mailbox -Identity John.Doe@ACME.org -SoftDeletedMailbox | Remove-Mailbox -PermanentlyDelete