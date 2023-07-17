#Prompts User for Location and runs command to get NTFS Permission information of the location
$Path = Read-Host -Prompt 'Please enter the Path of the Folder you would like to see NTFS Permissions on'
(get-acl $Path).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -Autosize

$Continue = Read-Host -Prompt 'Would you like to search another directory? (Y/N)'

#Loop for re-runing the program based on User Input of (Y/N)
If ($Continue -eq "Y"){
    do{
    $Path = Read-Host -Prompt 'Please enter the Path of the Folder you would like to see NTFS Permissions on'
    (get-acl $Path).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto

    $Continue = Read-Host -Prompt 'Would you like to search another directory? (Y/N)'
        }until($Continue -eq 'N')
    }
    ElseIf($Continue -eq 'N'){
        Exit
    }
