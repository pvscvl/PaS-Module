
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
    	} 
	if ($macAddress -match "^([0-9A-Fa-f]{12})$") {
        	$macAddress = $macAddress.ToUpper()        
        	$macAddress = $macAddress -replace '(.{2})', '$1:'
        	$macAddress = $macAddress.TrimEnd(':')
        	return $macAddress
	}
	Write-Host "Invalid MAC address format"
	return $null
}

function Generate-IPMILicense {
	param (
        	[string]$macAddress
	)

	if ($macAddress -ne '') { 
		$VALIDMAC = Convert-ToMacAddress $macAddress
		if ($VALIDMAC -eq $null) { break } 
	}

	if ($macAddress -eq '') {
		Write-Output ""
		Write-Host "Enter MAC-Address of SuperMicro IPMI Interface."
		$MBMACADDR = (Read-Host "MAC-Address").Replace(' ', '').Replace(':', '').Replace('-', '')
		$VALIDMAC = Convert-ToMacAddress $MBMACADDR
		Write-Output ""
		if ($VALIDMAC -eq $null) { break } 
	}
	
	$MACBYTES = [System.Linq.Enumerable]::Range(0, $MBMACADDR.Length / 2) | ForEach-Object { [Convert]::ToByte($MBMACADDR.Substring($_ * 2, 2), 16) }
	$MACSHA1 = New-Object System.Security.Cryptography.HMACSHA1
	$MACSHA1.Key = [Convert]::FromHexString('8544E3B47ECA58F9583043F8')
	$HASHBYTES = $MACSHA1.ComputeHash($MACBYTES)
	$HASHHEX = ([BitConverter]::ToString($HASHBYTES) -replace '-').Substring(0, 24)
	$LICENSEKEY = ($HASHHEX -split "(.{4})", 6 | Where-Object { $_ }) -join '-'
	Write-Output "`tMAC-Address:"
	Write-Output "`t$VALIDMAC"
	Write-Output ""
	Write-Output "`tLicense Key:"
	Write-Output "`t$LICENSEKEY "
	Write-Output ""
}

