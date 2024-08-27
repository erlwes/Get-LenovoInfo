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

## Visual example - Single serial, brief product specification
![image](https://github.com/user-attachments/assets/de28f708-6eea-46b7-8f4b-baf0c6c8bce1)
