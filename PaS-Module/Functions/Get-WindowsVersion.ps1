function Get-WindowsVersion{
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tN/A"
		return
	}

	$BuildNumberToWindowsVersion = @{
		"9200" = "Windows 8 and Windows Server 2012 [Build  9200]"
		"9600" = "Windows 8.1 and Windows Server 2012 R2 [Build 9600]"
		"10240" = "Windows 10 - 1507 (RTM)`t[Build 10240]"
		"10586" = "Windows 10 - 1511`t[Build 10586] - End of servicing"
		"14393" = "Windows 10 - 1607 and Windows Server 2016 [Build 14393] - End of servicing"
		"15063" = "Windows 10 - 1703`t[Build 15063] - End of servicing"
		"16299" = "Windows 10 - 1709`t[Build 16299] - End of servicing"	
		"17134" = "Windows 10 - 1803`t[Build 17134] - End of servicing"
		"17763" = "Windows 10 - 1809 and Windows Server 2019 [Build 17763]"
		"18362" = "Windows 10 - 1903`t[Build 18362] - End of servicing"
		"18363" = "Windows 10 - 1909`t[Build 18363] - End of servicing"
		"19041" = "Windows 10 - 2004`t[Build 19041] - End of servicing"
		"19042" = "Windows 10 - 20H2`t[Build 19042] - End of servicing"
		"19043" = "Windows 10 - 21H1`t[Build 19043] - End of servicing"
		"19044" = "Windows 10 - 21H2`t[Build 19044] - End of servicing"
		"19045" = "Windows 10 - 22H2`t[Build 19045]"
		"22000" = "Windows 11 - 21H2`t[Build 22000]"
		"20348" = "Windows Server 2022`t[Build 20348]"
		"22621" = "Windows 11 - 22H2`t[Build 22621]"
		"22631" = "Windows 11 - 23H2`t[Build 22631]"
	}

	$buildNumber = (Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
	$winVersion = $BuildNumberToWindowsVersion[$buildNumber]
	Write-Host "$Computer`t$winVersion"
} 
