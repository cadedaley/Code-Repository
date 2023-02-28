#Creates Registry Folders needed for Intouch before installation
New-Item -Path HKCU:\SOFTWARE\"VB and VBA Program Settings"\ -Name "Intouch"
New-Item -Path HKCU:\SOFTWARE\"VB and VBA Program Settings"\Intouch -Name "Local"

#Sets the Server IP Address for Intouch
Set-ItemProperty -Path HKCU:\SOFTWARE\"VB and VBA Program Settings"\Intouch\Local\ -Name "ServerIPAddress" -Value "172.27.116.123"

#Installs Intouch
start \\172.27.116.123\Intouch\Publish\Intouch.application

Start-Sleep -Seconds 3 
[System.Windows.Forms.SendKeys]::SendWait("{LEFT}{ENTER}")