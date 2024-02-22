function Test-OnlineStatus {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	$ping = Test-Connection -ComputerName $Computer -Count 1 -Quiet
	return $ping
}


