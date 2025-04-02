# Checks Path for defined overly permissive folders
 
 param(
    ### Enter Target Path Here ###
    [string]$TargetPath = "\\Enter\Path\Here" # Edit Here!
)

# Exclude default administrative shares and hidden shares
$excludedShares = @("ADMIN$", "C$", "D$", "E$", "F$", "IPC$") # Extend this list if needed

# Function to check shares and permissions
function Check-SharesAndPermissions {
    param(
        [string]$path
    )
    
    $foundSharedFolders = $false
    $foundOverlyPermissiveFolders = $false
    $overlyPermissiveFolders = @()
    
    # Define the list of groups to check for potential over-permissiveness, this can be edited!
    $overlyPermissiveGroups = @("Everyone", "Authenticated Users", "Domain Users", "Guests", "Users", "NETWORK SERVICE", "LOCAL SERVICE", "SYSTEM", "Anonymous Logon")

    # List all shared folders and their permissions
    Write-Host "Shared Folders and Their Permissions in ${path}:" -ForegroundColor Cyan
    Get-ChildItem -Path $path -Directory -Recurse | ForEach-Object {
        $foundSharedFolders = $true
        $folderPath = $_.FullName
        Write-Host "`nFolder Path: $folderPath"
        $acl = (Get-Item $folderPath).GetAccessControl('Access')
        $acl.Access | ForEach-Object {
            Write-Host "$($_.IdentityReference) : $($_.FileSystemRights)"
            if ($overlyPermissiveGroups -contains $_.IdentityReference.Value) {
                $foundOverlyPermissiveFolders = $true
                $overlyPermissiveFolders += [PSCustomObject]@{
                    FolderPath = $folderPath
                    Group = $_.IdentityReference
                    Rights = $_.FileSystemRights
                }
            }
        }
    }

    if (-not $foundSharedFolders) {
        Write-Host "No shared folders found in ${path}." -ForegroundColor Yellow
    }

    if ($foundOverlyPermissiveFolders) {
        Write-Host "`nOverly Permissive Folders in ${path}:" -ForegroundColor Cyan
        foreach ($item in $overlyPermissiveFolders) {
            Write-Host "$($item.FolderPath) has permissions for $($item.Group) with rights $($item.Rights)"
        }
    } else {
        Write-Host "`n ----- No overly permissive folders found in ${path}.-----" -ForegroundColor Yellow
    }
}

# Check if TargetPath is provided
if ([string]::IsNullOrWhiteSpace($TargetPath)) {
    Write-Host "No target path specified. Exiting script." -ForegroundColor Red
    exit
}

# Call the function with the specified path
Check-SharesAndPermissions -path $TargetPath
