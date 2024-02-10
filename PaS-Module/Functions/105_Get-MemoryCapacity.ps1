function Get-MemoryCapacity {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Test-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}

		$MEMORY = (Get-CimInstance -ComputerName $Computer -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
        Write-Host "$Computer`tMemory: $MEMORY GB"
}

