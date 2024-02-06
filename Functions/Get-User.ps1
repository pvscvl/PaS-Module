function Get-User {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tOffline"
		return
	}
	query user /server:$Computer
} 