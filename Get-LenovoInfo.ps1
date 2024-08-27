<#PSScriptInfo

    .VERSION 1.6.0
    .GUID 2ec72304-ff34-4f42-bd0c-2211df4d9074
    .AUTHOR Erlend Westervik
    .COMPANYNAME
    .COPYRIGHT
    .TAGS Device, Warranty, Lenovo, Hardware, Age, Warranties, Endpoint, Management, Serialnumber, Serial, Product, Model, Manufacturer, Specification, Specc
    .LICENSEURI
    .PROJECTURI https://github.com/erlwes/Get-LenovoInfo
    .ICONURI
    .EXTERNALMODULEDEPENDENCIES 
    .REQUIREDSCRIPTS
    .EXTERNALSCRIPTDEPENDENCIES
    .RELEASENOTES        
        Version: 1.0.0 - Original published version
        Version: 1.1.0 - Rewrite. New baseline.
        Version: 1.5.0 - Added 'ShowCachesCombined' + fixed some output that got pre-formated
        Version: 1.6.0 - Added 'VerboseLogging'-parameter and changed default cache location to script location instead of current directory.
#>

<#
.SYNOPSIS
    Get product specifications and warranty information of Lenovo device using serialnumber.

.DESCRIPTION
    The scripts will create a local CSV-file cache, and then add warranty and/or product specifications for every serialnumber that is queried, and store it to the cache.
    If the serialnumber/model-code does not exist in cache (eg. first time queried), the script will go online and fetch warranty and/or product spec info from Lenovo web-services.
    In addition to the standard output from Lenovo web-pages, days left of warranty or days since expired will be calculated, alog with an aproximate age of the computer using (years since waranty start)

.PARAMETER Serialnumber
    One or more serialnumber(s) that you want to get warranty and/or product specs for.

.PARAMETER Type
    What type of information to query. This can be 'Warranty' or 'ProductSpecification'. Default 'Warranty'.

.PARAMETER Brief
    Warranty: Shows only base product warranties. If more than one, show premium/on-site support warranty
    Product: Output limited to the most essential hardware components of product

.PARAMETER InspectCache
    Shows content in exising offline cache file(s). Pipe results to gridview for easy filtering and searching.

.PARAMETER ClearCache
    Deletes one or more offline cache file(s) from disk.

.PARAMETER ShowCachesCombined
    Shows selected info on all devices that exist in local cache. Pipe results to gridview for easy filtering and searching.

.PARAMETER VerboseLogging
    Logging to console.

.EXAMPLE
    .\Get-LenovoInfo.ps1 -Serialnumber 'PF0A0BBB' -Type Warranty
    
    This example will return the product warranties for the Lenovo computer with serialnumber 'PF0A0BBB'

.EXAMPLE
    .\Get-LenovoInfo.ps1 -Serialnumber 'PF0A0BBB' -Type ProductSpecification -Brief | Format-Table *
    
    This example will return a brief overview of the product specifications of a Lenovo computer with serialnumber 'PF0A0BBB'
#>
param(
    [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
    [string]$Serialnumber,

    [Parameter(Mandatory = $false)]
    [switch]$Brief,

    [Parameter(Mandatory = $false)][ValidateSet('Warranty', 'ProductSpecification')]
    [string]$Type = 'Warranty',

    [Parameter(Mandatory = $false)]
    [switch]$ForceWeb,

    [Parameter(Mandatory = $false)][ValidateSet('Warranty', 'ProductSpecification', 'ProductID')]
    [string]$InspectCache,

    [Parameter(Mandatory = $false)][ValidateSet('All','Warranty', 'ProductSpecification', 'ProductID')]
    [string]$ClearCache,

    [Parameter(Mandatory = $false)]
    [Switch]$ShowCachesCombined,

    [Parameter(Mandatory = $false)]
    [Switch]$VerboseLogging
)
begin {
    if ($Brief) {
        $Properties = @(
            @{Expression={$_.DeliveryType -replace 'depot', 'Depot/mail' -replace 'on_site', 'On site'};Label='DeliveryType'},
            @{Expression={$_.ProductName -replace "\(.+$"};Label='ProductName'},
            @{Expression={$_.Model};Label='Model'},
            @{Expression={$_.SerialNumber};Label='SerialNumber'},
            @{Expression={$_.Name};Label='Name'},
            @{Expression={$_.Status -replace '-1', 'Expired' -replace '1', 'Active'};Label='Status'},     
            @{Expression={((Get-Date $_.End) - (Get-date)).TotalDays -replace "(,|\.).+$"};Label='DaysLeft'},
            @{Expression={$_.YearsSinceBought};Label='YearsSinceBought'}
        )
    }
    else {
        $Properties = @(
            @{Expression={$_.WarrentyType};Label='WarrentyType'},
            @{Expression={$_.DeliveryType -replace 'depot', 'Depot/mail' -replace 'on_site', 'On site'};Label='DeliveryType'},
            @{Expression={$_.ProductName};Label='ProductName'},
            @{Expression={$_.Model};Label='Model'},
            @{Expression={$_.SerialNumber};Label='SerialNumber'},
            @{Expression={$_.Name};Label='Name'},
            @{Expression={$_.Description};Label='Description'},
            @{Expression={$_.Status -replace '-1', 'Expired' -replace '1', 'Active'};Label='Status'},
            @{Expression={$_.Start};Label='Start'},
            @{Expression={$_.End};Label='End'},
            @{Expression={$_.Duration};Label='Duration'},
            @{Expression={((Get-Date $_.End) - (Get-date)).TotalDays -replace "(,|\.).+$"};Label='DaysLeft'},
            @{Expression={$_.Origin};Label='Origin'},
            @{Expression={$_.CountryName};Label='CountryName'}
            @{Expression={$_.YearsSinceBought};Label='YearsSinceBought'}
        )
    }

    $Script:CacheProductID = @()
    $Script:CacheWarranty = @()    
    $Script:CacheProductSpecification = @()

    $Script:ProductIDResults = @()
    $Script:WarrantyResults = @()
    $Script:SpecResults = @()

    $Script:CacheFileProductID = "$PSScriptRoot\Get-LenovoInfo-ProductIDCache.csv"
    $Script:CacheFileWarranty = "$PSScriptRoot\Get-LenovoInfo-WarrantyCache.csv"
    $Script:CacheFileProductSpecifications = "$PSScriptRoot\Get-LenovoInfo-ProductSpecificationsCache.csv"

    Function Write-Log {
        param(
            [ValidateSet(0, 1, 2, 3, 4)]
            [int]$Level,

            [Parameter(Mandatory=$true)]
            [string]$Message            
        )
        $Message = $Message.Replace("`r",'').Replace("`n",' ')
        switch ($Level) {
            0 { $Status = 'Info'    ;$FGColor = 'White'   }
            1 { $Status = 'Success' ;$FGColor = 'Green'   }
            2 { $Status = 'Warning' ;$FGColor = 'Yellow'  }
            3 { $Status = 'Error'   ;$FGColor = 'Red'     }
            4 { $Status = 'Console' ;$FGColor = 'Gray'    }
            Default { $Status = ''  ;$FGColor = 'Black'   }
        }
        if ($VerboseLogging) {
            Write-Host "$((Get-Date).ToString()) " -ForegroundColor 'DarkGray' -NoNewline
            Write-Host "$Status" -ForegroundColor $FGColor -NoNewline

            if ($level -eq 4) {
                Write-Host ("`t " + $Message) -ForegroundColor 'Cyan'
            }
            else {
                Write-Host ("`t " + $Message) -ForegroundColor 'White'
            }
        }
        if ($Level -eq 3) {
            $LogErrors += $Message
        }
    }
    Function Invoke-ProductIDWebRequest {
        Param(
            [String]$Serialnumber
        )
        try {
            Clear-Variable Url -ErrorAction SilentlyContinue            
            $Url = "https://pcsupport.lenovo.com/gb/en/api/v4/mse/getproducts?productId=$SerialNumber" #CASE-SENSITIVE!

            Clear-Variable Response -ErrorAction SilentlyContinue
            $Response = Invoke-WebRequest -Uri $Url -ErrorAction Stop

            Clear-Variable Product -Scope script -ErrorAction SilentlyContinue
            $Script:ProductWebResponse = $Response.Content | ConvertFrom-Json

            Write-Log -Level 1 -Message "Invoke-WebRequest - ProductID: $($Response.StatusCode) $($Response.StatusDescription) '$Url'"

            if (!$Script:ProductWebResponse.id) {
                Write-Log -Level 2 -Message "Invoke-WebRequest - ProductID: Incomplete response. Product ID not found for serialnumber '$Serialnumber'"
            }
            else {
                $Product = [pscustomobject]@{
                    SerialNumber    = $SerialNumber
                    ProductID       = $Script:ProductWebResponse.Id
                    ModelCode       = ($Script:ProductWebResponse.Id -split '/')[-2]
                }
                $Script:CacheProductID += $Product
                $Script:CacheResultProductID = $Product

                try {
                    if (!$ForceWeb) {
                        $Product | Export-Csv -Path $Script:CacheFileProductID -Delimiter ';' -Encoding utf8 -Append -Force
                        Write-Log -Level 1 -Message "CSV Cache Product ID - Product ID for serialnumber '$Serialnumber' added to cache"
                    }
                }
                catch {
                    Write-Log -Level 3 -Message "CSV Cache Product ID - Failed to add product ID for serialnumber  '$Serialnumber' to cache $($_.Exception.Message)"
                }
            }
        }
        catch {
            Write-Log -Level 3 -Message "Invoke-WebRequest - ProductID: $($Response.StatusCode) $($Response.StatusDescription) '$Url', Error: $($_.Exception.Message)"
        }
    }
    Function Invoke-ProductSpecificationWebRequest {
        param(
            [String]$ModelCode,
            [String]$Serialnumber
        )
        try {
            Clear-Variable Url -ErrorAction SilentlyContinue
            $Url = "https://psref.lenovo.com/api/model/Info/SpecData?model_code=$ModelCode"

            Clear-Variable Response -ErrorAction SilentlyContinue
            $Response = Invoke-WebRequest -Uri $Url -ErrorAction Stop
            
            Clear-Variable Specs -ErrorAction SilentlyContinue
            $Specs = $Response | ConvertFrom-Json

            Write-Log -Level 1 -Message "Invoke-WebRequest - Product Specification: $($Response.StatusCode) $($Response.StatusDescription) '$Url'"
        }
        catch {
            Write-Log -Level 3 -Message "Invoke-WebRequest - Product Specification: $($Response.StatusCode) $($Response.StatusDescription) '$Url', Error: $($_.Exception.Message)"
        }

        if ($Specs.data) {
            # Loop all components

            $Parts = @()
            $Specs.data.SpecData | Select-Object Title, Name, Content | ForEach-Object {                
                $Part = [pscustomobject]@{
                    Serial          = $Serialnumber
                    ModelCode       = $ModelCode                    
                    Part            = $_.Name
                    Value           = ($_ | Select-Object -ExpandProperty content) -replace "(&reg;|&trade;)" -replace '\<.+>' -replace "(\r\n|\n|\r)", "" -replace '(USB-C).+$', 'USB-C'
                }
                $Parts += $Part
            }

            # Add each component to the script result variable
            $Script:SpecResults += $Parts

            # Update imported cache with new live-entries, discarding serialnumber...
            $Script:CacheProductSpecification += $Parts | Select-Object ModelCode, Part, Value

            try {
                if (!$ForceWeb) {
                    # Export the results to offline cache file, discarding serialnumber
                    $Parts | Select-Object ModelCode, Part, Value | Export-Csv -Path $Script:CacheFileProductSpecifications -Delimiter ';' -Encoding utf8 -Append -Force                    
                    Write-Log -Level 1 -Message "Offline Cache - Product Specifications: Model '$ModelCode' added to cache"
                }
            }
            catch {
                Write-Log -Level 3 -Message "Offline Cache - Product Specifications: Failed to add model '$ModelCode' to cache $($_.Exception.Message)"
            }
        }        
        else {
            Write-Log -Level 2 -Message "Invoke-WebRequest - Product Specification: Incomplete response. Product specification not found for model code '$ModelCode'"
        }
        
    }
    Function Invoke-WarrantyWebRequest {
        Param(
            [String]$Serialnumber,
            [String]$ProductID
        )
        if ($ProductID) {
            try {
                Clear-Variable Url -ErrorAction SilentlyContinue
                $Url = 'https://pcsupport.lenovo.com/us/en/products/' + $ProductID.ToLower() + '/warranty'

                Clear-Variable Result -ErrorAction SilentlyContinue
                $Result = Invoke-WebRequest -uri $Url -ErrorAction Stop

                Write-Log -Level 1 -Message "Invoke-WebRequest - Warranty: $($Result.StatusCode) $($Result.StatusDescription) '$Url'"
            }
            catch {
                Write-Log -Level 3 -Message "Invoke-WebRequest - Warranty: $($Result.StatusCode) $($Result.StatusDescription) '$Url', Error: $($_.Exception.Message)"
            }
        }

        # Parse HTML and extract JSON
        if ($Result) {
            Clear-Variable PSObject -ErrorAction SilentlyContinue
            $PSObject = ((($Result.content -split "`n") | Where-Object {$_ -match 'var ds_warranties'}) -replace 'var ds_warranties = window.ds_warranties \|\| ' -replace ';$') | ConvertFrom-Json
        }

        if ($PSObject) {

            $Warranties = @()
            $Warranties += $PSObject.BaseWarranties
            $Warranties += $PSObject.UpmaWarranties
            $Warranties += $PSObject.AodWarranties
            $Warranties += $PSObject.InstantWarranties
            $Warranties += $PSObject.SaeWarranties

            $Warranties | ForEach-Object {
                Clear-Variable Warranty -ErrorAction SilentlyContinue
                $Warranty = $_
                $ApproximateAgeInYears = (((Get-Date) - (Get-Date $Warranty.Start)).TotalDays / 365)
                try {
                    $Obj = [pscustomobject]@{
                        WarrentyType        = $Warranty.WarrentyType
                        DeliveryType        = $Warranty.DeliveryType
                        ProductName         = $PSObject.ProductName
                        Model               = ($PSObject.MachineType, $PSObject.Mode -join '')
                        SerialNumber        = $PSObject.Serial
                        Name                = $Warranty.Name
                        Description         = $Warranty.Description
                        Status              = $Warranty.Status
                        Start               = $Warranty.Start
                        End                 = $Warranty.End
                        Duration            = $Warranty.Duration
                        Origin              = $Warranty.Origin
                        CountryName         = $Warranty.CountryName
                        YearsSinceBought    = [math]::Round($ApproximateAgeInYears,2)
                    }
                    $Script:WarrantyResults += $Obj
                    $Script:CacheWarranty += $Obj
                    
                    if (!$ForceWeb) {
                        $Obj | Export-Csv -Delimiter ';' -Path $Script:CacheFileWarranty -Append -Encoding utf8 -Force -ErrorAction Stop
                        Write-Log -Level 1 -Message "Offline Cache - Warranty $($Warranty.Name) for serialnumber '$Serialnumber' added to cache"
                    }
                }
                catch {
                    Write-Log -Level 3 -Message "Offline Cache - Failed to add Warranty $($Warranty.Name) for serialnumber '$Serialnumber' to cache $($_.Exception.Message)"
                }
            }
        }
        else {
            Write-Log -Level 3 -Message "Invoke-WebRequest - Warranty: Failed for serialnumber '$Serialnumber'"
        }
    }
     Function Import-CSVCache {
        Param([string]$File)
        try {
            if ($File -match 'WarrantyCache') {
                $Script:CacheWarranty += Import-Csv $File -Delimiter ';' -Encoding utf8
                Write-Log -Level 1 -Message "Offline Cache - File loaded ($($Script:CacheWarranty.count) entries)"
            }
            elseif ($File -match 'ProductSpecificationsCache') {
                $Script:CacheProductSpecification += Import-Csv $File -Delimiter ';' -Encoding utf8
                Write-Log -Level 1 -Message "Offline Cache - File loaded ($($Script:CacheProductSpecification.count) entries)"
            }
            elseif ($File -match 'ProductID') {                
                $Script:CacheProductID += Import-Csv $File -Delimiter ';' -Encoding utf8
                Write-Log -Level 1 -Message "Offline Cache - File loaded ($($Script:CacheProductID.count) entries)"
            }
        }
        catch {
            Write-Log -Level 3 -Message "Offline Cache - Failed to load file $($_.Exception.Message)"
        }
    }
    function Clear-CSVCache {
        Param($File)
        try {
            Remove-Item $File -Force -ErrorAction Stop
            Write-Log -Level 1 -Message "Remove-Item - File '$File' was deleted"
        }
        catch {
            if ($_.Exception.Message -match 'not exist') {
                Write-Log -Level 2 -Message "Remove-Item - Cache file did not exist '$File'"
            }
            else {
                Write-Log -Level 3 -Message "Remove-Item - Failed to delete file '$File' $($_.Exception.Message)"
            }
        }
    }
    function Test-CSVCache {
        Param($File)
        if (Test-Path $File) {
            Write-Log -Level 0 -Message "Offline Cache - File exist ('$File')"
            Import-CSVCache -File $File
        }
        else {
            Write-Log -Level 0 -Message "Offline Cache - File not found ('$File')"
        }
    }
    Function Test-CSVProductIDCacheMatch {
        Param(
            [String]$Serialnumber
        )
        if ($Script:CacheProductID -and !$ForceWeb) {
            Clear-Variable CacheResultProductID -Scope Script -ErrorAction SilentlyContinue
            $Script:CacheResultProductID = $Script:CacheProductID | Where-Object {$_.SerialNumber -eq $Serialnumber}

            if ($Script:CacheResultProductID) {
                Write-Log -Level 0 -Message "Offline Cache - Product ID: Serialnumber '$Serialnumber' found in cache"
            }
            else {
                Write-Log -Level 0 -Message "Offline Cache - Product ID: Serialnumber '$Serialnumber' not found in cache"
            }
        }
    }
    Function Test-CSVProductSpecificationCacheMatch {
        Param(
            [String]$ModelCode,
            [String]$Serialnumber
        )
        if ($Script:CacheProductSpecification) {
            Clear-Variable CacheResultsSpecification -Scope Script -ErrorAction SilentlyContinue
            $Script:CacheResultsSpecification = $Script:CacheProductSpecification | Where-Object {$_.ModelCode -eq $ModelCode}

            if ($CacheResultsSpecification -and !$ForceWeb) {
                $Script:CacheResultsSpecification | Add-Member -MemberType NoteProperty -Name Serial -Value $Serialnumber -Force
                $Script:SpecResults += $CacheResultsSpecification
                Write-Log -Level 0 -Message "Offline Cache - Product Specifications: Model '$ModelCode' found in cache"
            }
            else {
                Write-Log -Level 0 -Message "Offline Cache - Product Specifications: Model '$ModelCode' not found in cache"
            }
        }
    }
    Function Test-CSVWarrantyCacheMatch {
        Param([String]$Serialnumber)
        Clear-Variable CacheResultsWarranty -Scope Script -ErrorAction SilentlyContinue
        $Script:CacheResultsWarranty = $Script:CacheWarranty | Where-Object {$_.SerialNumber -eq $Serialnumber}
        if ($Script:CacheResultsWarranty -and !$ForceWeb) {
            $Script:WarrantyResults += $Script:CacheResultsWarranty
            Write-Log -Level 0 -Message "Offline Cache - Warranty: Serialnumber '$Serialnumber' found in cache"
        }
        else {
            Write-Log -Level 0 -Message "Offline Cache - Warranty: Serialnumber '$Serialnumber' not found in cache"
        }
    }

    # Load needed offline cache from CSV files if they exist
    Test-CSVCache -File $Script:CacheFileProductID
    if ($Type -eq 'Warranty' -or $InspectCache -eq 'Warranty' -or $ShowCachesCombined)               {Test-CSVCache -File $Script:CacheFileWarranty      }
    if ($Type -eq 'ProductSpecification' -or $InspectCache -eq 'ProductSpecification' -or $ShowCachesCombined)   {Test-CSVCache -File $Script:CacheFileProductSpecifications}

    # Load needed offline cache from CSV files if they exist
    if ($InspectCache) {
        Write-Log -Level 2 -Message "Parameter '-InspectCache' used. Displaying cache for '$InspectCache', ignoring other parameters"        
        if ($InspectCache -eq 'Warranty') {
            Return $Script:CacheWarranty
        }
        elseif ($InspectCache -eq 'ProductSpecification') {
            Return $Script:CacheProductSpecification
        }
        elseif ($InspectCache -eq 'ProductID') {
            Return $Script:CacheProductID
        }
        Break
    }

    if ($ShowCachesCombined) {
        $Script:Devices = @()
        $Script:CacheProductID | ForEach-Object {
            Clear-Variable SerialNumber, ModelCode -ErrorAction SilentlyContinue
            $Serialnumber = $_.SerialNumber
            $ModelCode = $_.ModelCode

            if ($Serialnumber -and $ModelCode) {

                Clear-Variable WarrantyMatch, ProductSpecificationMatch -ErrorAction SilentlyContinue            
                $WarrantyMatch = $Script:CacheWarranty | Where-Object {$_.SerialNumber -eq $Serialnumber -and $_.Name -notmatch 'Battery'} | Select-Object -Last 1                        
                $ProductSpecificationMatch = $Script:CacheProductSpecification | Where-Object {$_.ModelCode -match $ModelCode}

                if ($WarrantyMatch -and $ProductSpecificationMatch) {
                    Clear-Variable Device, DeviceAge -ErrorAction SilentlyContinue
                    $DeviceAge = (((Get-Date) - (Get-Date $WarrantyMatch.Start)).TotalDays / 365)

                    $Device = [pscustomobject]@{
                        Serial              = [string]$Serialnumber
                        ModelCode           = [string]$ModelCode
                        ProductName         = [string]$WarrantyMatch.ProductName -replace "\(.+$"
                        WarrantyName        = [string]$WarrantyMatch.Name
                        WarrantyDaysLeft    = [int](((Get-Date $WarrantyMatch.End) - (Get-date)).TotalDays -replace "(,|\.).+$")
                        DeviceAge           = [decimal]([math]::Round($DeviceAge,2))
                        DeviceMemory        = [string]($ProductSpecificationMatch | Where-Object {$_.Part -eq 'Memory'}          | Select-Object -ExpandProperty Value)
                        DeviceProcessor     = [string]($ProductSpecificationMatch | Where-Object {$_.Part -eq 'Processor'}       | Select-Object -ExpandProperty Value)
                        DeviceStorage       = [string]($ProductSpecificationMatch | Where-Object {$_.Part -eq 'Storage'}         | Select-Object -ExpandProperty Value)
                        DeviceSecurityChip  = [string]($ProductSpecificationMatch | Where-Object {$_.Part -eq 'Security Chip'}   | Select-Object -ExpandProperty Value)
                    }
                    $Script:Devices += $Device
                }
            }
        }        
    }

    # Delete offline CSV cache-file
    if($ClearCache) {
        Write-Log -Level 2 -Message "Parameter '-ClearCache' used. Deleting offline cache-file(s)"
        if ($ClearCache -match '(All|ProductID)')               {Clear-CSVCache -File $Script:CacheFileProductID}
        if ($ClearCache -match '(All|ProductSpecification)')    {Clear-CSVCache -File $Script:CacheFileProductSpecifications}
        if ($ClearCache -match '(All|Warranty)')                {Clear-CSVCache -File $Script:CacheFileWarranty}
    }

    if ($ForceWeb) {
        Write-Log -Level 2 -Message "Parameter '-ForceWeb' used. Cache is excluded (not used, and results are not added to cache)"
    }
}
process {
    if (!$ShowCachesCombined -and !$InspectCache) {
        if ($Serialnumber) {
            Test-CSVProductIDCacheMatch -Serialnumber $Serialnumber

            if (!$Script:CacheResultProductID -or $ForceWeb) {
                Invoke-ProductIDWebRequest -Serialnumber $Serialnumber
            }

            if ($Script:CacheResultProductID) {

                if ($Type -eq 'ProductSpecification') {
                    Test-CSVProductSpecificationCacheMatch -ModelCode $Script:CacheResultProductID.ModelCode -Serialnumber $Serialnumber
                    if (!$Script:CacheResultsSpecification -or $ForceWeb) {
                        Invoke-ProductSpecificationWebRequest -ModelCode $Script:CacheResultProductID.ModelCode -Serialnumber $Serialnumber
                    }
                }

                if ($Type -match 'Warranty') {
                    Test-CSVWarrantyCacheMatch -Serialnumber $Serialnumber
                    if (!$Script:CacheResultsWarranty -or $ForceWeb) {
                        Invoke-WarrantyWebRequest -Serialnumber $Serialnumber -ProductID $Script:CacheResultProductID.ProductID
                    }
                }

            }
        }
        else {
            Write-Log -Level 2 -Message 'No input provided. Please input one or more serialnumbers'
        }
    }
}
end {
    if (!$ShowCachesCombined -and !$InspectCache) {         
        if ($Type -eq 'Warranty') {
            if ($Brief) {
                if ($Script:WarrantyResults.Name -match 'Premier') {
                    $Output = $Script:WarrantyResults | Where-Object {$_.Name -match 'Premier'} | Select-Object $Properties
                }
                else {
                    $Output = $Script:WarrantyResults | Where-Object {$_.Name -notmatch 'Battery'} | Select-Object $Properties
                }
            }
            else {
                $Output = $Script:WarrantyResults | Select-Object $Properties
            }
        }
        elseif ($Type -eq 'ProductSpecification') {        
            if ($Brief) {
                $Output = $Script:SpecResults | Where-Object {$_.Part -match "(Processor|Graphics|Memory|Storage|Display|WLAN)"} | Select-Object ModelCode, Part, Value
            }
            else {
                $Output = $Script:SpecResults
            }
        }
        Return $Output
    }
    else {        
        Return $Script:Devices
    }
}
