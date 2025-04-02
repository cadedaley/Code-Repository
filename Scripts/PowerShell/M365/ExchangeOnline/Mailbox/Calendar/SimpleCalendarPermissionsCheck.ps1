### Check Calendar Access for User ###

Get-MailboxFolderStatistics -Identity UID_HERE | Where-Object { $_.Identity -like "*Calendar*" } | FT Identity