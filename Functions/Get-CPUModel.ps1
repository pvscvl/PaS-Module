function Get-CPUModel {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tOffline"
		return
	}
	
        Write-Host -NoNewline "$Computer`tCPU: "
        (Get-WmiObject -ComputerName $Computer -ClassName Win32_Processor).Name
}