function Get-DiskInformation {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	
	if (-Not (Get-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}

	$disks = Get-CimInstance -ComputerName $Computer -ClassName Win32_DiskDrive
	foreach ($disk in $disks) {
		$SizeInGB = [math]::round($disk.Size / 1GB, 2)
		$MediaType = $disk.MediaType
		Write-Host "$Computer Disk ($($disk.DeviceID)):`t Size = $SizeInGB GB, Type = $MediaType"
	}
}

