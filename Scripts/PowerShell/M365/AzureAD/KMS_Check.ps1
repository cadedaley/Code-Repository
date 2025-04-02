<#
.SYNOPSIS
    This script reports the current license status of a Windows host, checks if it is using KMS, verifies if it is part of a domain, retrieves DNS server information, and checks the DNS KMS settings if applicable.

.DESCRIPTION
    The script performs the following tasks:
    - Retrieves and displays the current license status.
    - Checks if the host is using a KMS server.
    - Verifies if the host is part of a domain.
    - Retrieves DNS server information.
    - If part of a domain, queries DNS for KMS SRV records.

.NOTES
    File Name  : LicenseStatusReport.ps1
    Author     : Craig Wilson
    Version    : 1.4
    Last Updated: 2024-06-06
    Disclaimer : Provided with no warranty. Use at your own risk.

.PARAMETER None
    This script does not take any parameters.

.EXAMPLE
    To run this script, open PowerShell with administrative privileges and execute the script as follows:
    .\LicenseStatusReport.ps1

#>

# Function to get the OS information
function Get-OSInfo {
    <#
    .SYNOPSIS
        Retrieves the operating system information of the host.

    .DESCRIPTION
        This function uses the 'Get-WmiObject' cmdlet to query the OS information.

    .OUTPUTS
        [PSCustomObject] The operating system information.

    .EXAMPLE
        $osInfo = Get-OSInfo
    #>
    $os = Get-WmiObject -Class Win32_OperatingSystem
    [PSCustomObject]@{
        "Name"        = $os.Caption
        "Version"     = $os.Version
        "BuildNumber" = $os.BuildNumber
        "Architecture"= $os.OSArchitecture
    }
}

# Function to get the current KMS server
function Get-KmsServer {
    <#
    .SYNOPSIS
        Retrieves the current KMS server configured on the host.

    .DESCRIPTION
        This function uses the 'Get-WmiObject' cmdlet to query the KMS server configuration.

    .OUTPUTS
        [string] The KMS server name if configured, otherwise $null.

    .EXAMPLE
        $kmsServer = Get-KmsServer
    #>
    $kmsInfo = Get-WmiObject -Query "SELECT KeyManagementServiceMachine FROM SoftwareLicensingProduct WHERE ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f'"
    if ($kmsInfo -and $kmsInfo.KeyManagementServiceMachine -ne "") {
        return $kmsInfo.KeyManagementServiceMachine.Trim()
    } else {
        return $null
    }
}

# Function to get the machine's domain status
function Get-DomainStatus {
    <#
    .SYNOPSIS
        Checks if the host is part of a domain.

    .DESCRIPTION
        This function uses WMI to determine if the machine is part of a domain by comparing the domain and workgroup names.

    .OUTPUTS
        [string] The domain name if the machine is part of a domain, otherwise $null.

    .EXAMPLE
        $domain = Get-DomainStatus
    #>
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $domain = $computerSystem.Domain
    $workgroup = $computerSystem.Workgroup
    if ($domain -ne $workgroup) {
        return $domain
    } else {
        return $null
    }
}

# Function to test the DNS KMS settings
function Test-KmsDnsSettings {
    <#
    .SYNOPSIS
        Queries DNS for KMS SRV records if the host is part of a domain.

    .DESCRIPTION
        This function queries DNS for the KMS SRV record (_vlmcs._tcp) within the domain if the host is part of a domain.

    .EXAMPLE
        Test-KmsDnsSettings
    #>
    $kmsDnsRecord = "_vlmcs._tcp"
    $domain = Get-DomainStatus

    if ($domain) {
        try {
            Write-Host "Querying DNS for KMS SRV record in domain $domain..."
            $dnsQuery = Resolve-DnsName -Name "$kmsDnsRecord.$domain" -Type SRV -ErrorAction Stop
            if ($dnsQuery) {
                Write-Host "KMS DNS setting found:"
                $dnsQuery | Format-Table -AutoSize
            } else {
                Write-Host "No KMS DNS setting found."
            }
        } catch {
            Write-Host "Failed to query DNS for KMS. Error: $_"
        }
    } else {
        Write-Host "Machine is not part of a domain."
    }
}

# Function to get the current license status
function Get-LicenseStatus {
    <#
    .SYNOPSIS
        Retrieves and displays the current license status of the host.

    .DESCRIPTION
        This function uses the 'Get-WmiObject' cmdlet to query and display the current license status, filtering to show only licensed products.

    .EXAMPLE
        Get-LicenseStatus
    #>
    Write-Host "Checking current license status..."
    $licenseStatus = Get-WmiObject -Query "SELECT Description, LicenseStatus FROM SoftwareLicensingProduct"
    $licensedProducts = $licenseStatus | Where-Object { $_.LicenseStatus -eq 1 }
    $licensedProducts | Select-Object Description, LicenseStatus
}

# Function to get DNS server information
function Get-DnsServers {
    <#
    .SYNOPSIS
        Retrieves the DNS server information of the host.

    .DESCRIPTION
        This function uses the 'Get-DnsClientServerAddress' cmdlet to query the DNS server information.

    .OUTPUTS
        [PSCustomObject] The DNS server information.

    .EXAMPLE
        $dnsServers = Get-DnsServers
    #>
    $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4
    $dnsServers | Select-Object -ExpandProperty ServerAddresses | ForEach-Object {
        [PSCustomObject]@{
            "DNS Server" = $_
        }
    }
}

# Main script execution
Write-Host "Starting license status report..."
$executionTime = Get-Date
Write-Host "Execution Time: $executionTime"
Write-Host "-----------------------------------------------------------------------------------"

# Get OS Information
$osInfo = Get-OSInfo
Write-Host "- Operating System Information                                                   -"
Write-Host "----------------------------------------------------------------------------------"
$osInfo | Format-Table -AutoSize -HideTableHeaders

# Check and get license status
$licensedProducts = Get-LicenseStatus
Write-Host "-----------------------------------------------------------------------------------"
Write-Host "- Checking Licenses via WMI                                                       -"
Write-Host "-----------------------------------------------------------------------------------"
Write-Host "Licensed Products:"
$licensedProducts | Format-Table -AutoSize -HideTableHeaders

$totalLicensed = $licensedProducts.Count
Write-Host "Total licensed products: $totalLicensed"
Write-Host "-----------------------------------------------------------------------------------"

# Check if using KMS
Write-Host "-----------------------------------------------------------------------------------"
Write-Host "- Checking KMS Licensing via DNS                                                  -"
Write-Host "-----------------------------------------------------------------------------------"
$kmsServer = Get-KmsServer
if ($kmsServer) {
    Write-Host "Using KMS server: $kmsServer"
} else {
    Write-Host "No KMS server configured."
}

# Check if part of a domain
$domain = Get-DomainStatus
if ($domain) {
    Write-Host "Machine is part of the domain: $domain"
} else {
    Write-Host "Machine is not part of a domain."
}

# Test DNS KMS settings if part of a domain
if ($domain) {
    Test-KmsDnsSettings
}

# Get DNS Server Information
Write-Host "-----------------------------------------------------------------------------------"
Write-Host "- DNS Server Information                                                          -"
Write-Host "-----------------------------------------------------------------------------------"
$dnsServers = Get-DnsServers
$dnsServers | Format-Table -AutoSize

Write-Host "-----------------------------------------------------------------------------------"
Write-Host "License status report completed."
Write-Host "-----------------------------------------------------------------------------------"
Write-Host "Execution Time: $executionTime"

Pause