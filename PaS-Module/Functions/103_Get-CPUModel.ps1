function Get-CPUModel {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Test-WinRMStatus -Computer $Computer)) {
		$Computer = $Computer.ToUpper()
		Write-Host "$Computer`tN/A"
		return
	}
		$Computer = $Computer.ToUpper()
        Write-Host -NoNewline "$Computer`tCPU: "
        (Get-CimInstance -ComputerName $Computer -ClassName Win32_Processor).Name
}

