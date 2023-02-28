@echo off 
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'Hello, Your ADB Files are downloading.', 'This may take a few minutes.', [System.Windows.Forms.ToolTipIcon]::None)}"

xcopy /s /i "\\USBNS00DGSR01\software$\RFGun Files\ADB" "C:\adb"
