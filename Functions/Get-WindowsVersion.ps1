function Get-WindowsVersion{
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tOffline"
		return
	}

	$BuildNumberToWindowsVersion = @{
		"9200" = "Windows 8 and Windows Server 2012 (Build 9200)"
		"9600" = "Windows 8.1 and Windows Server 2012 R2 (Build 9600)"
		"10240" = "Windows 10 Ver. 1507 (RTM) (Build 10240)"
		"10586" = "Windows 10 Ver. 1511 (Build 10586) - End of servicing"
		"14393" = "Windows 10 Ver. 1607 and Windows Server 2016 (Build 14393) - End of servicing"
		"15063" = "Windows 10 Ver. 1703 (Build 15063) - End of servicing"
		"16299" = "Windows 10 Ver. 1709 (Build 16299) - End of servicing"	
		"17134" = "Windows 10 Ver. 1803 (Build 17134) - End of servicing"
		"17763" = "Windows 10 Ver. 1809 and Windows Server 2019 (Build 17763)"
		"18362" = "Windows 10 Ver. 1903 (Build 18362) - End of servicing"
		"18363" = "Windows 10 Ver. 1909 (Build 18363) - End of servicing"
		"19041" = "Windows 10 Ver. 2004 (Build 19041) - End of servicing"
		"19042" = "Windows 10 Ver. 20H2 (Build 19042) - End of servicing"
		"19043" = "Windows 10 Ver. 21H1 (Build 19043) - End of servicing"
		"19044" = "Windows 10 Ver. 21H2 (Build 19044) - End of servicing"
		"19045" = "Windows 10 Ver. 22H2 (Build 19045)"
		"22000" = "Windows 11 Ver. 21H2 (Build 22000)"
		"20348" = "Windows Server 2022 (Build 20348)"
		"22621" = "Windows 11 Ver. 22H2 (Build 22621)"
		"22631" = "Windows 11 Ver. 23H2 (Build 22631)"
	}

	$buildNumber = (Get-WmiObject -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
	$winVersion = $BuildNumberToWindowsVersion[$buildNumber]
	Write-Host "$Computer - $winVersion"
} 
