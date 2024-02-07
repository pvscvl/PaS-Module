function Get-DiskInformation {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	if (-Not (Get-OnlineStatus -Computer $Computer)) {
        Write-Host "$Computer`tOffline"
	return
	}
	
	if (-Not (Get-WinRMStatuswip -Computer $Computer)) {
		Write-Host "$Computer`tNo Remote Management possible"
		return
	}
	
	


	$disks = Get-CimInstance -ComputerName $Computer -ClassName Win32_DiskDrive
	foreach ($disk in $disks) {
		$SizeInGB = [math]::round($disk.Size / 1GB, 2)
		$MediaType = $disk.MediaType
		Write-Host "$Computer Disk ($($disk.DeviceID)):`t Size = $SizeInGB GB, Type = $MediaType"
	}
}