function Get-WinRMStatus {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	$wsmanResult = Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue
	if ($wsmanResult) {
		return $true
	}
	else {
		return $false
	}
}