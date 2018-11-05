function Connect-Yubikey {
    $USBDevices = Get-VirtualBoxUSB
    $VM = Get-VirturalBoxRunningVM
    $YubikeyObject = $USBDevices | Where-Object { $_.Product -like "Yubikey*"}
    & $Env:VBoxManage controlvm $VM.Name usbattach $YubikeyObject.UUID
}
function Disconnect-Yubikey {
    $USBDevices = Get-VirtualBoxUSB
    $VM = Get-VirturalBoxRunningVM
    $YubikeyObject = $USBDevices | Where-Object { $_.Product -like "Yubikey*"}
    & $Env:VBoxManage controlvm $VM.Name usbdetach $YubikeyObject.UUID
}
function Get-VirturalBoxRunningVM {
    $RunningVMOutput = & $Env:VBoxManage list runningvms
    $VM = New-Object -TypeName PSObject
    $VMName = $RunningVMOutput.split(' ')[0].trim('"')
    $VMUUID = $RunningVMOutput.split(' ')[1].trim('{').trim('}')
    $VM | Add-Member NoteProperty -Name Name -Value $VMName
    $VM | Add-Member NoteProperty -Name UUID -Value $VMUUID
    return $VM
}
function  ConvertTo-VirtualBoxUSBItem {
    param (
        # USB VirtualBox Item
        [Parameter(Mandatory=$true)]
        [Array]
        $USBItem
    )
    $USBObject = New-Object -TypeName PSObject
    foreach ($U in $USBItem){
        if ($U -eq ""){
            continue
        }
        else {
            $key = $U.split(':',2)[0].trim()
            $value = $U.split(':',2)[1].trim()
            $USBObject | Add-Member NoteProperty -Name $key -Value $value
        }
    }
    return $USBObject
    
}

function Get-VirtualBoxUSB {
    $USBHostOutput = & $Env:VBoxManage list usbhost
    $VBoxUSBItems = @()
    # Start iterator at 2. First two lines are irrelevenat
    $SeperatorLocations = @()
    for ($i=2; $i -lt $USBHostOutput.Length; $i++){
       if ($USBHostOutput[$i] -eq ""){
           $SeperatorLocations += $i
       }
    }
    for ($i=0; $i -le $SeperatorLocations.Length; $i++){
        $LastLineofUSBItem = $SeperatorLocations[$i] - 1
        if ($i -eq 0){
            $item = $USBHostOutput[2..$LastLineofUSBItem]
            $VBoxUSBItems += ConvertTo-VirtualBoxUSBItem($item)
        }
        elseif ($i -eq $SeperatorLocations.Length){
            $PreviousSeperator= $SeperatorLocations[($i - 1)]
            $item = $USBHostOutput[$PreviousSeperator..$USBHostOutput.Length]
            $VBoxUSBItems += ConvertTo-VirtualBoxUSBItem($item)
        }
        else {
            $PreviousSeperator= $SeperatorLocations[($i - 1)]
            $item = $USBHostOutput[$PreviousSeperator..$LastLineofUSBItem]
            $VBoxUSBItems += ConvertTo-VirtualBoxUSBItem($item)
        }
    }
    return $VBoxUSBItems
}