function Get-DiskInformation {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	$Computer = $Computer.ToUpper()
	if (-Not (Get-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}

	$disks = get-cimInstance -ComputerName $Computer -ClassName MSFT_PhysicalDisk -Namespace root\Microsoft\Windows\Storage
	foreach ($disk in $disks) {
 		$DeviceID = $disk.FriendlyName
		$SizeInGB = [math]::round($disk.Size / 1GB, 2)
		$MediaType = $disk.MediaType
		$BusType = $disk.BusType
		Write-Host "$Computer -`t$DeviceID `t$SizeInGB GB`t$MediaType / $BusType"
	}
}

