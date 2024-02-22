function Get-MACAddress {
	param(
		[Parameter(Mandatory=$true, Position=0)]
		[string]$IPAddressOrHostname
	)

	try {
		$isIP = [bool](([System.Net.IPAddress]::TryParse($IPAddressOrHostname, [ref]$null)))
		if ($isIP) {
			$IPAddress = $IPAddressOrHostname
		} else {
			$IPAddress = [System.Net.Dns]::GetHostAddresses($IPAddressOrHostname) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1 -ExpandProperty IPAddressToString
		}

		if (-not $IPAddress) {
			Write-Host "Failed to resolve IP address or hostname: $IPAddressOrHostname" -ForegroundColor Red
			return $null
		}

		if (-Not (Test-OnlineStatus -Computer $IPAddress)) {
			return $null
		}  

		$arpOutput = arp -a | Where-Object { $_ -like "*$IPAddress*" }
		if ($arpOutput) {
			$macAddress = ($arpOutput -replace '\s+', ' ' -split ' ' | Select-Object -Index 2).ToUpper() -replace '-', ':'
			if ($macAddress -match '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
				return $macAddress
			} else {
				return $null
			}
		} else {
			return $null
		}
	} catch {
		return $null
	}
}

