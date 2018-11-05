Import-Module .\VBoxYubikey.psm1 -Force
$Env:VBoxManage = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
Connect-yubikey
Disconnect-Yubikey