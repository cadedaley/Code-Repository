#Script to Delete Users Downloads folder.

# Get the current user's username
$username = $env:UserName

# Get the current user's Downloads folder path
$downloadsFolder = "C:\Users\$username\Downloads"

# Delete everything in the Downloads folder
Get-ChildItem $downloadsFolder -Force -Recurse | Remove-Item -Force -Recurse
