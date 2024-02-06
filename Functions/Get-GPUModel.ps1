function Get-GPUModel {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	
	if (-Not (Get-OnlineStatus -Computer $Computer)) {
        Write-Host "$Computer`tOffline"
	return
	}
	
	$GPUs = Get-CimInstance -ComputerName $Computer -ClassName Win32_VideoController | Where-Object {$_.Name -notmatch 'DameWare'}
	foreach ($GPU in $GPUs) {
		Write-Host "$Computer - GPU:`t $($GPU.Name)"
	}
}