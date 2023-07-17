# This task adds the current user with Full Control to the specified folder. Very niche.

﻿# Get the current user
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

# Get the specified folder
$folderPath = "C:\Test"

# Get the access control list for the folder
$acl = Get-Acl $folderPath

# Create a new access control entry for the current user
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser,"FullControl","Allow")

# Add the access control entry to the access control list
$acl.AddAccessRule($ace)

# Set the access control list for the folder
Set-Acl $folderPath $acl
