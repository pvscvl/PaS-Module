function Test-WinRMStatus {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
	#	return (Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) -ne $null
		return $null -ne (Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) 
	} else {
		return $false
	}
}


