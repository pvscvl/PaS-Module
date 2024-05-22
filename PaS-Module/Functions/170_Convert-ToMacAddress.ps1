function Convert-ToMacAddress {
	param (
		[string]$macAddress
	)
	if ($macAddress -match "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$") {
		$macAddress = $macAddress -replace '[:-]', ''
		$macAddress = $macAddress.ToUpper()
		$macAddress = $macAddress -replace '(.{2})', '$1:'
		$macAddress = $macAddress.TrimEnd(':')
		return $macAddress
		echo -n $macAddress | Set-Clipboard

	} 
	
	if ($macAddress -match "^([0-9A-Fa-f]{12})$") {
		$macAddress = $macAddress.ToUpper()        
		$macAddress = $macAddress -replace '(.{2})', '$1:'
		$macAddress = $macAddress.TrimEnd(':')
		return $macAddress
		echo -n $macAddress | Set-Clipboard

	}

	Write-Host "Invalid MAC address."
	return $null
}