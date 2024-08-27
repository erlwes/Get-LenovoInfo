# Get-LenovoInfo
Script designed to retrieve and manage product specifications and warranty information for Lenovo devices using their serialnumbers.

## Description
When a serial number is queried, the script checks the local cache to see if the information is already available. If not, it fetches the data from Lenovo's web services, adds it to the cache, and then provides the requested details.
The cache reduce the need for repeated online queries - this improves performance and offloads Lenovos APIs.

### Screenshot 1 - Brief warranty
![image](https://github.com/user-attachments/assets/b9dbbd62-b2d9-419b-8903-8c5f687f7609)

### Screenshot 2 - Brief product specification
![image](https://github.com/user-attachments/assets/2ec54acd-8535-40cf-8393-60d2a035da2a)

## Install
```PowerShell
Install-Script -Name Get-LenovoInfo
```

## TIPS 💡

**Device age** - I found that using warranty start-date and todays date is good for calculating aproximate computer age. Sometimes one wants to identify the oldest computers so that one can prioritize replacement. Looking at CPU-generations etc. can be cumbersome.
The scripts calculates this age in years and presents it as "YearsSinceBought"

**Hardware requirements** - The product specification includes detailed hardware info on all devices. As an example, one could easiliy identify computers with < 8GB memory, or computers without a TPM 2.0 chip, and therefore not ready for Windows 11.

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


## 🔵 Example 4 - Combined cache
```PowerShell
Get-LenovoInfo -ShowCachesCombined | Format-Table *
```
```
Serial  	ModelCode 		ProductName     	WarrantyName      	WarrantyDaysLeft	DeviceAge	DeviceMemory              		DeviceProcessor                                                                          	DeviceStorage
------  	--------- 		-----------     	------------      	----------------	---------	------------              		---------------                                                                          	-------------
PC29DABC	20XF006RMX		T14s Gen 2      	1Y Premier Support	            -554	     2,52	16GB Soldered LPDDR4x-4266		AMD Ryzen 7 PRO 5850U (8C / 16T, 1.9 / 4.4GHz, 4MB L2 / 16MB L3)                         	512GB SSD M.2 2280 PCIe x4 NVMe Opal 2.0
PF4GBABC	21F6002NMX		T14s Gen 4      	3Y Premier Support	             715	     1,04	16GB Soldered LPDDR5x-4800		Intel Core i5-1335U, 10C (2P + 8E) / 12T, P-core 1.3 / 4.6GHz, E-core 0.9 / 3.4GHz, 12MB 	256GB SSD M.2 2280 PCIe 4.0x4 NVMe Opal 2.0
PF29GABC	20T0001NMX		T14s            	3Y On-site, 9X5   	            -335	     3,92	16GB Soldered DDR4-2666   		Intel Core i5-10210U (4C / 8T, 1.6 / 4.2GHz, 6MB)                                        	256GB SSD M.2 2280 PCIe x4 NVMe Opal
GM03NABC	21BR00F2MX		T14s Gen 3      	3Y Premier Support	             661	     1,19	16GB Soldered LPDDR5-4800 		Intel Core i5-1250P, 12C (4P + 8E) / 16T, P-core 1.7 / 4.4GHz, E-core 1.2 / 3.3GHz, 12MB 	256GB SSD M.2 2280 PCIe x4 NVMe Opal 2.0
PW05QABC	21DE0029MX		X1 Extreme Gen 5	3Y Premier Support	             641	     1,24	1x 32GB SO-DIMM DDR5-4800 		Intel Core i7-12700H, 14C (6P + 8E) / 20T, P-core 2.3 / 4.7GHz, E-core 1.7 / 3.5GHz, 24MB	512GB SSD M.2 2280 PCIe 4.0x4 Performance NVMe Op…
GM00CABC	21BR00EXMX		T14s Gen 3      	3Y Premier Support	             523	     1,57	16GB Soldered LPDDR5-4800 		Intel Core i5-1240P, 12C (4P + 8E) / 16T, P-core 1.7 / 4.4GHz, E-core 1.2 / 3.3GHz, 12MB 	256GB SSD M.2 2280 PCIe x4 NVMe Opal 2.0
```

## 🔵 Example 5 - Clear the cache
```PowerShell
Get-LenovoInfo -Serialnumber -ClearCache All
```

## 🔵 Example 6 - Get warranty on local machine
```PowerShell
(wmic bios get serialnumber)[2] | Get-LenovoInfo -Type Warranty
```
```
WarrentyType     : 3EZ
DeliveryType     : Depot/mail
ProductName      : T14s Gen 3 (Type 21BR 21BS) Laptop (ThinkPad) - Type 21BR
Model            : 21BR002AMX
SerialNumber     : PF3WABCD
Name             : 3Y Depot, 9X5 2BD Warranty
Description      : This product has a three year limited warranty and is entitled to depot/Carry-in repair service. Customers may call their local service center for more info
                   rmation. Dealers may provide carry-in repair for this product. Batteries have a one year warranty. If pen comes with the product, pen  is entitled to one ye
                   ar warranty.
Status           : Active
Start            : 2022-09-14
End              : 2025-09-13
Duration         : 36
DaysLeft         : 381
Origin           : Purchased Warranty
CountryName      : Denmark
YearsSinceBought : 1,96

WarrentyType     : 1EZBAT
DeliveryType     : Depot/mail
ProductName      : T14s Gen 3 (Type 21BR 21BS) Laptop (ThinkPad) - Type 21BR
Model            : 21BR002AMX
SerialNumber     : PF3WABCD
Name             : 1YR Battery (Carry-in/Depot Warranty)
Description      : The battery included within this product is entitled to a 1 year CRU/Depot/Carry-in warranty.  Please note that this may differ from the warranty of the bas
                   e product itself.
Status           : Expired
Start            : 2022-09-14
End              : 2023-09-13
Duration         : 12
DaysLeft         : -349
Origin           : Purchased Warranty
CountryName      : Denmark
YearsSinceBought : 1,96

WarrentyType     : UKN
DeliveryType     : On site
ProductName      : T14s Gen 3 (Type 21BR 21BS) Laptop (ThinkPad) - Type 21BR
Model            : 21BR002AMX
SerialNumber     : PF3WABCD
Name             : 3Y Premier Support
Description      : This machine is entitled to a warranty upgrade of 3 year of Premier Support service.
Status           : Active
Start            : 2022-09-14
End              : 2025-09-13
Duration         : 36
DaysLeft         : 381
Origin           : Purchased Warranty
CountryName      : Denmark
YearsSinceBought : 1,96
```

## 🔵 Example 7 - Full product specification
```PowerShell
Get-LenovoInfo -Serialnumber PF3WABCD -Type ProductSpecification
```
```
ModelCode  Part                        Value                                                                                    Serial
---------  ----                        -----                                                                                    ------
21BR002AMX Processor                   Intel Core i5-1240P, 12C (4P + 8E) / 16T, P-core 1.7 / 4.4GHz, E-core 1.2 / 3.3GHz, 12MB PF3WABCD
21BR002AMX Graphics                    Integrated Intel Iris Xe Graphics                                                        PF3WABCD
21BR002AMX Chipset                     Intel SoC Platform                                                                       PF3WABCD
21BR002AMX Memory                      16GB Soldered LPDDR5-4800                                                                PF3WABCD
21BR002AMX Memory Slots                Memory soldered to systemboard, no slots, dual-channel                                   PF3WABCD
21BR002AMX Max Memory                  16GB soldered memory, not upgradable                                                     PF3WABCD
21BR002AMX Storage                     256GB SSD M.2 2280 PCIe x4 NVMe Opal 2.0                                                 PF3WABCD
21BR002AMX Storage Support             One drive, up to 2TB M.2 2280 SSD                                                        PF3WABCD
21BR002AMX Storage Slot                One M.2 2280 PCIe 4.0 x4 slot                                                            PF3WABCD
21BR002AMX Card Reader                 None                                                                                     PF3WABCD
21BR002AMX Optical                     None                                                                                     PF3WABCD
21BR002AMX Audio Chip                  High Definition (HD) Audio, Realtek ALC3287 codec                                        PF3WABCD
21BR002AMX Speakers                    Stereo speakers, 2W x2, Dolby Audio                                                      PF3WABCD
21BR002AMX Camera                      FHD 1080p + IR Hybrid with Privacy Shutter                                               PF3WABCD
21BR002AMX Microphone                  2x, Array                                                                                PF3WABCD
21BR002AMX Battery                     Integrated 57Wh                                                                          PF3WABCD
21BR002AMX Power Adapter               65W USB-C                                                                                PF3WABCD
21BR002AMX Display                     14" WUXGA (1920x1200) IPS 400nits Anti-glare, 100% sRGB, Low Power                       PF3WABCD
21BR002AMX Touchscreen                 None                                                                                     PF3WABCD
21BR002AMX Keyboard                    Backlit, Nordic (DK/FI/NO/SV)                                                            PF3WABCD
21BR002AMX Case Color                  Thunder Black                                                                            PF3WABCD
21BR002AMX Case Material               Carbon Fiber Hybrid (Top), Aluminium (Bottom)                                            PF3WABCD
21BR002AMX Dimensions (WxDxH)          317.5 x 226.9 x 16.9 mm (12.5 x 8.93 x 0.67 inches)                                      PF3WABCD
21BR002AMX Weight                      Starting at 1.21 kg (2.67 lbs)                                                           PF3WABCD
21BR002AMX Operating System            Windows 11 Pro, Nordic (DK/FI/SV/NO/EN)                                                  PF3WABCD
21BR002AMX Bundled Software            Intel Connectivity Performance Suite                                                     PF3WABCD
21BR002AMX Ethernet                    No Onboard Ethernet                                                                      PF3WABCD
21BR002AMX WLAN + Bluetooth            Intel Wi-Fi 6E AX211, 802.11ax 2x2 + BT5.1                                               PF3WABCD
21BR002AMX WWAN                        WWAN Upgradable to 4G                                                                    PF3WABCD
21BR002AMX SIM Card                    None                                                                                     PF3WABCD
21BR002AMX NFC                         None                                                                                     PF3WABCD
21BR002AMX Standard Ports              System.Object[]                                                                          PF3WABCD
21BR002AMX Optional Ports (configured) System.Object[]                                                                          PF3WABCD
21BR002AMX Docking                     Various docking solutions supported via Thunderbolt / USB-C                              PF3WABCD
21BR002AMX Smart Card Reader           Smart Card Reader                                                                        PF3WABCD
21BR002AMX Security Chip               Discrete TPM 2.0 Enabled                                                                 PF3WABCD
21BR002AMX Fingerprint Reader          Touch Style, Match-on-Chip, Integrated in Power Button                                   PF3WABCD
21BR002AMX Physical Locks              Kensington Nano Security Slot, 2.5 x 6 mm                                                PF3WABCD
21BR002AMX Other Security              System.Object[]                                                                          PF3WABCD
21BR002AMX System Management           Non-vPro                                                                                 PF3WABCD
21BR002AMX Base Warranty               3-year, Courier or Carry-in                                                              PF3WABCD
21BR002AMX Included Upgrade            CO2 Offset 1 ton, 3Y Premier Support HB (CPN)                                            PF3WABCD
21BR002AMX Bundled Accessories         None                                                                                     PF3WABCD
21BR002AMX Green Certifications        System.Object[]                                                                          PF3WABCD
21BR002AMX Other Certifications        System.Object[]                                                                          PF3WABCD
21BR002AMX Mil-Spec Test               MIL-STD-810H military test passed                                                        PF3WABCD
```

## 🔵 Example 8 - Warranty bypassing offline cache (-ForceWeb) with logging to console (-VerboseLogging)
```PowerShell
Get-LenovoInfo -Serialnumber PF3WABCD -Brief -Type ProductSpecification -VerboseLogging -ForceWeb
```
```
27.08.2024 20:14:22 Info         Offline Cache - File exist ('C:\Users\Temp\...\Get-LenovoInfo-ProductIDCache.csv')
27.08.2024 20:14:22 Success      Offline Cache - File loaded (1 entries)
27.08.2024 20:14:22 Info         Offline Cache - File exist ('C:\Users\Temp\...\Get-LenovoInfo-ProductSpecificationsCache.csv')
27.08.2024 20:14:22 Success      Offline Cache - File loaded (46 entries)
27.08.2024 20:14:22 Warning      Parameter '-ForceWeb' used. Cache is excluded (not used, and results are not added to cache)
27.08.2024 20:14:22 Success      Invoke-WebRequest - ProductID: 200 OK 'https://pcsupport.lenovo.com/gb/en/api/v4/mse/getproducts?productId=PF3WABCD'
27.08.2024 20:14:22 Info         Offline Cache - Product Specifications: Model '21BR002AMX' not found in cache
27.08.2024 20:14:22 Success      Invoke-WebRequest - Product Specification: 200 OK 'https://psref.lenovo.com/api/model/Info/SpecData?model_code=21BR002AMX'
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
