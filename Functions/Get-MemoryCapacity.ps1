function Get-MemoryCapacity {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tOffline"
		return
	}

        $MEMORY = (Get-WmiObject -ComputerName $Computer -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
        Write-Host "$Computer`tMemory: $MEMORY GB"
}