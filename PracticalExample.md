# Lookup info on all Lenovo devices in Intune/Endpoint manager

### Step 1 - Export devices from Intune/Endpoint manager to a CSV-file
1. Go to Endpoint Manager portal and click "Devices"
2. Click "Export" and choose the alternative that exports all data to file (we need the serial number)


### Performing lookup for all Lenovo-devices in export file, keeping device name
```PowerShell
$PathToIntuneDeviceExport = 'C:\Users\Temp\Downloads\DevicesWithInventory.csv'
$IntuneLenovoDevices = Import-Csv $PathToIntuneDeviceExport -Delimiter ',' -Encoding utf8 | Where-Object {$_.Manufacturer -eq 'LENOVO'} | select -first 10

$MergedResults = @()
$IntuneLenovoDevices | ForEach-Object {
    Clear-Variable Result -ErrorAction SilentlyContinue
    $Result = Get-LenovoInfo -Serialnumber $_.'Serial number' -Type Warranty -Brief
    
    #Join in desired fields from the Intune device export. I'm keeping device name only, but primary user etc. could be usefull as well.
    $Result | Add-Member -MemberType NoteProperty -Name ComputerName -Value $_.'Device name'

    $MergedResults += $Result
}
$MergedResults | Select-Object ComputerName, ProductName, Model, SerialNumber, Name, Status, DaysLeft, YearsSinceBought | Format-Table *
```

### Results (adding device name from CSV-export)
```
ComputerName   ProductName Model      SerialNumber Name                       Status DaysLeft YearsSinceBought
------------   ----------- -----      ------------ ----                       ------ -------- ----------------
OSL-ERLWES-T14 T14s Gen 2  20XF006RMX PC29DABC     3Y Depot, 9X5 2BD Warranty Active 179      2,51
BER-OLANOR-P14 T14s Gen 2  20WM009AMX PC241ABC     3Y Depot, 9X5 2BD Warranty Active 47       2,87
STA-KARNOR-T14 T14s Gen 2  20WM009AMX PC241ABC     3Y Depot, 9X5 2BD Warranty Active 47       2,87
```
