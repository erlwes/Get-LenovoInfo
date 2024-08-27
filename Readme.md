# Get-LenovoInfo
Get product information and warranty of a Lenovo PC from a serialnumber

I have been using this method for ~2 years and it has been stable. If Lenovo changes their web-services, it could easiliy break. Lenovo does have a API, but I have had no luck in requesting a API key 🤷‍♂️

## TIPS 💡
I found that using warranty start-date and todays date is good for calculating aproximate computer age. Sometimes one wants to identify the oldest computers so that one can prioritize replacement. Looking at CPU-generations etc. can be cumbersome.
The scripts calculates this age in years and presents it as "YearsSinceBought"

## Install
```PowerShell
Install-Script -Name Get-LenovoInfo
```


## 🔵 Example 1 - Warranty lookup, brief output
```PowerShell
Get-LenovoInfo -Serialnumber PC29DABC -Brief
```
```
DeliveryType     : On site
ProductName      : T14s Gen 4
Model            : 21F6002NMX
SerialNumber     : PC29DABC
Name             : 3Y Premier Support
Status           : Active
DaysLeft         : 674
YearsSinceBought : 1,28
```

## 🔵 Example 2 - Product specification lookup, brief output
```PowerShell
Get-LenovoInfo.ps1 -Serialnumber PC29DABC -Brief -Type ProductSpecification
```
```
ModelCode  Part             Value
---------  ----             -----
21BR002AMX Processor        Intel Core i5-1240P, 12C (4P + 8E) / 16T, P-core 1.7 / 4.4GHz, E-core 1.2 / 3.3GHz, 12MB
21BR002AMX Graphics         Integrated Intel Iris Xe Graphics
21BR002AMX Memory           16GB Soldered LPDDR5-4800
21BR002AMX Memory Slots     Memory soldered to systemboard, no slots, dual-channel
21BR002AMX Max Memory       16GB soldered memory, not upgradable
21BR002AMX Storage          256GB SSD M.2 2280 PCIe x4 NVMe Opal 2.0
21BR002AMX Storage Support  One drive, up to 2TB M.2 2280 SSD
21BR002AMX Storage Slot     One M.2 2280 PCIe 4.0 x4 slot
21BR002AMX Display          14" WUXGA (1920x1200) IPS 400nits Anti-glare, 100% sRGB, Low Power
21BR002AMX WLAN + Bluetooth Intel Wi-Fi 6E AX211, 802.11ax 2x2 + BT5.1
```


## 🔵 Example 3 - Multiple from pipeline, warranty sorted and formated as table
```PowerShell
'GM0CDABC', 'PF4A2ABC', 'GM03NABC', 'PC29DABC' | Get-LenovoInfo.ps1 -Brief | Sort YearsSinceBought | Format-Table
```
```
DeliveryType ProductName Model      SerialNumber Name               Status  DaysLeft YearsSinceBought
------------ ----------- -----      ------------ ----               ------  -------- ----------------
On site      T14s Gen 4  21F6002NMX GM0CDABC     3Y Premier Support Active  887      0,57
On site      T14s Gen 4  21F6002NMX PF4A2ABC     3Y Premier Support Active  674      1,28
On site      T14s Gen 3  21BR00F2MX GM03NABC     3Y Premier Support Active  582      1,41
On site      T14s Gen 2  20XF006RMX PC29DABC     1Y Premier Support Expired -551     2,51
```


## 🔵 Example 4 - Warranty, full output (default)
```PowerShell
Get-LenovoInfo.ps1 -Serialnumber PC29DABC
```
```
WarrentyType     : 3EZ
DeliveryType     : Depot/mail
ProductName      : T14s Gen 4 (Type 21F6, 21F7) Laptop (ThinkPad) - Type 21F6
Model            : 21F6002NMX
SerialNumber     : PC29DABC
Name             : 3Y Depot, 9X5 2BD Warranty
Description      : This product has a three year limited warranty and is entitled to depot/Carry-in repair service. Customers may call their local service center for more info
                   rmation. Dealers may provide carry-in repair for this product. Batteries have a one year warranty. If pen comes with the product, pen  is entitled to one ye
                   ar warranty.
Status           : Active
Start            : 2023-05-17
End              : 2026-06-30
Duration         : 36
DaysLeft         : 674
Origin           : Factory Warranty
CountryName      : Sweden
YearsSinceBought : 1,28

WarrentyType     : 1EZBAT
DeliveryType     : Depot/mail
ProductName      : T14s Gen 4 (Type 21F6, 21F7) Laptop (ThinkPad) - Type 21F6
Model            : 21F6002NMX
SerialNumber     : PC29DABC
Name             : 1YR Battery (Carry-in/Depot Warranty)
Description      : The battery included within this product is entitled to a 1 year CRU/Depot/Carry-in warranty.  Please note that this may differ from the warranty of the bas
                   e product itself.
Status           : Expired
Start            : 2023-05-17
End              : 2024-06-30
Duration         : 12
DaysLeft         : -55
Origin           : Factory Warranty
CountryName      : Sweden
YearsSinceBought : 1,28

WarrentyType     : UKN
DeliveryType     : On site
ProductName      : T14s Gen 4 (Type 21F6, 21F7) Laptop (ThinkPad) - Type 21F6
Model            : 21F6002NMX
SerialNumber     : PC29DABC
Name             : 3Y Premier Support
Description      : This machine is entitled to a warranty upgrade of 3 year of Premier Support service.
Status           : Active
Start            : 2023-05-17
End              : 2026-06-30
Duration         : 36
DaysLeft         : 674
Origin           : Factory Warranty
CountryName      : Sweden
YearsSinceBought : 1,28
```

## 🔵 Example 4 - Bypass cache and get raw webresults
```PowerShell
Get-LenovoWarranty -Serialnumber 'PF4A2ABC' -ForceWeb -RawWebResult
```
The raw output reveals additional info like CO2-offset in tons, link to product image and more:
```
IsSolution             : False
ProductId              : LAPTOPS-AND-NETBOOKS/THINKPAD-T-SERIES-LAPTOPS/THINKPAD-T14S-GEN-4-TYPE-21F6-21F7/21F6/21F6002NMX/PF4A2ABC
ProductName            : T14s Gen 4 (Type 21F6, 21F7) Laptop (ThinkPad) - Type 21F6
ProductImage           : https://download.lenovo.com/images/ProdImageLaptops/tp_t14s.jpg
BaseProductId          : PF4A2ABC
FullProductId          : LAPTOPS-AND-NETBOOKS/THINKPAD-T-SERIES-LAPTOPS/THINKPAD-T14S-GEN-4-TYPE-21F6-21F7/21F6/21F6002NMX/PF4A2ABC
MachineType            : 21F6
Mode                   : 002NMX
Serial                 : PF4A2ABC
Imei                   :
MTM                    : 002NMX
ManufactureDate        :
Status                 : True
X86Contract            : @{ContracsListRestructure=System.Object[]}
WarrantyUpgradeURLInfo : @{WarrantyURL=https://www.lenovo.com/se/sv/warrantyApos?IPromoID=LEN930148&serialNumber=PF4A2ABC; Method=; SerialNumberField=; AdditionalFields=; UserCountry=; IsShowURL=False}
IsShowUpGrade          : False
IsPremier              : True
SpecialSupport         : Premier
ContractWarranties     : {}
IsShowContractWarranty : False
IsShowWarning          : True
BaseUpmaWarranties     : {@{End=2026-06-30; Status=1; StatusV2=Active}, @{End=2026-06-30; Status=1; StatusV2=Active}}
BaseWarranties         : {@{Start=2023-05-17; End=2026-06-30; Status=1; WarrentyType=3EZ; Description=This product has a three year limited warranty and is entitled to depot/Carry-in repair service. Customers may ca
                         ll their local service center for more information. Dealers may provide carry-in repair for this product. Batteries have a one year warranty. If pen comes with the product, pen  is entitled
                         to one year warranty.; CountryCode=SE; CountryName=Sweden; Channel=; Origin=Factory Warranty; POPDate=-; Category=MACHINE; StatusV2=Active; DeliveryType=depot; Duration=36; Name=3Y Depot, 9X
                         5 2BD Warranty; IsPremier=False; Type=BASE; SortWeight=70; PremierService=}, @{Start=2023-05-17; End=2024-06-30; Status=-1; WarrentyType=1EZBAT; Description=The battery included within this
                         product is entitled to a 1 year CRU/Depot/Carry-in warranty.  Please note that this may differ from the warranty of the base product itself.; CountryCode=SE; CountryName=Sweden; Channel=; Or
                         igin=Factory Warranty; POPDate=-; Category=COMPONENT; StatusV2=Expired; DeliveryType=depot; Duration=12; Name=1YR Battery (Carry-in/Depot Warranty); IsPremier=False; Type=BASE; SortWeight=70
                         ; PremierService=}}
UpmaWarranties         : {@{Start=2023-05-17; End=2026-06-30; Status=1; WarrentyType=UKN; Description=This machine is entitled to a warranty upgrade of 3 year of Premier Support service.; CountryCode=SE; CountryName
                         =Sweden; Channel=; Origin=Factory Warranty; POPDate=-; Category=MACHINE; StatusV2=Active; DeliveryType=on_site; Duration=36; Name=3Y Premier Support; IsPremier=True; Type=UPGRADE; SortWeight
                         =50; PremierService=02}}
AodWarranties          : {}
InstantWarranties      : {}
SaeWarranties          : {}
ShipToCountry          : Sweden
Shiped                 : 2023-05-17
Country                : Sweden
RemainingDays          : 675
EntireWarrantyPeriod   : @{Start=1684281600000; End=1782777600000}
MtmPurchased           :
Source                 : IBASE
IsWarrantyRegistering  : False
CO2Offset              : @{ProjectId=CDM7178; ProjectName=Combined Cycle at Loma de la Tata; OffsetDate=20230608; CertificateID=CDM7178_4403044358-280999-2; Ton=0.5; Description=WARRANTY CO2 Offset 0.5 ton}
OtherServices          : {@{Start=2023-05-17; End=2023-07-31; Status=-1; WarrentyType=AL1; Description=This machine has been CO2 Offset.; CountryCode=; CountryName=; Channel=; Origin=Factory Warranty; POPDate=-; Cat
                         egory=MACHINE; StatusV2=Expired; DeliveryType=tech_support; Duration=1; Name=CO2 Offset; IsPremier=False; Type=UPGRADE; SortWeight=50; PremierService=}}
Software               : {}
```

## 🔵 Example 4 - Clear the cache
```PowerShell
Get-LenovoWarranty -Serialnumber -ClearCache
```

## Visual example 1 - Single serial, full output

![image](https://github.com/user-attachments/assets/de28f708-6eea-46b7-8f4b-baf0c6c8bce1)


## Visual example 2 - Multiple serials, brief output, sorted by computer age and displayed as table

![image](https://github.com/user-attachments/assets/d8d19e8c-ea20-456e-b8c5-e5c9cd67f9d6)
