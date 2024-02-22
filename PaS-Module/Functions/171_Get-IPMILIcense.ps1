function Get-IPMILicense {
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

