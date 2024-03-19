function Get-Uptime {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	$Computer = $Computer.ToUpper()
	if (-Not (Test-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}
	
	$LastBootUpTime = (Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem).LastBootUpTime
	$Uptime = New-TimeSpan -Start $LastBootUpTime -End (Get-Date)
	Write-Host "$Computer - System Uptime:`t $($Uptime.Days) days $($Uptime.Hours) hours $($Uptime.Minutes) minutes"
	Write-Host "$Computer - System Uptime:`t $($Uptime.Days) days $($Uptime.Hours) hours $($Uptime.Minutes) minutes $($Uptime.Seconds) seconds "
}

