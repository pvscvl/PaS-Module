function Test-oldWinRMStatus{
	param (
		[CmdletBinding()]
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

