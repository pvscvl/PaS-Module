function Get-NetworkDevices {
	# Helper function to format MAC address
	function Format-MacAddress {
	    param (
		[string]$mac
	    )
	    return ($mac -replace '(.{2})(?=.)', '$1:').ToLower()
	}
    
	# Get DHCP leases and reservations
	$dhcpServer = "10.0.0.81" # Replace with your DHCP server's name or IP
	$dhcpLeases = Get-DhcpServerv4Scope | ForEach-Object {
	    Get-DhcpServerv4Lease -ScopeId $_.ScopeId
	}
    
	$dhcpReservations = Get-DhcpServerv4Scope | ForEach-Object {
	    Get-DhcpServerv4Reservation -ScopeId $_.ScopeId
	}
    
	# Combine leases and reservations
	$dhcpData = $dhcpLeases + $dhcpReservations
    
	# Get DNS records
	$dnsServer = "10.0.0.81" # Replace with your DNS server's name or IP
	$dnsRecords = Get-DnsServerResourceRecord -ComputerName $dnsServer -ZoneName "." | Where-Object { $_.RecordType -eq "A" }
    
	# Create a list of known devices from DHCP
	$networkDevices = @()
    
	foreach ($lease in $dhcpData) {
	    $dnsRecord = $dnsRecords | Where-Object { $_.RecordData.IPv4Address -eq $lease.IPAddress }
	    $formattedMac = Format-MacAddress -mac $lease.ClientId
	    $networkDevices += [PSCustomObject]@{
		Hostname         = if ($dnsRecord) { $dnsRecord.HostName } else { "Unknown" }
		IPAddress        = $lease.IPAddress
		MACAddress       = $formattedMac
		MACAddressSearch = $lease.ClientId
		Source           = "DHCP"
		LeaseExpiry      = if ($lease.PSTypeNames -contains 'DhcpServerv4Lease') { $lease.LeaseExpiryTime } else { "Reservation" }
	    }
	}
    
	# Add devices with only DNS records (no DHCP lease)
	foreach ($dnsRecord in $dnsRecords) {
	    $ip = $dnsRecord.RecordData.IPv4Address
	    if (-not ($networkDevices.IPAddress -contains $ip)) {
		$networkDevices += [PSCustomObject]@{
		    Hostname         = $dnsRecord.HostName
		    IPAddress        = $ip
		    MACAddress       = "??:??:??:??:??:??"
		    MACAddressSearch = "N/A"
		    Source           = "DNS"
		    LeaseExpiry      = "N/A"
		}
	    }
	}
    
	# Display results in Out-GridView
	$networkDevices | Out-GridView -Title "Network Devices" -PassThru | Select-Object Hostname, IPAddress, MACAddress, MACAddressSearch, Source, LeaseExpiry
    }
    
    # Run the function
    Get-NetworkDevices
    