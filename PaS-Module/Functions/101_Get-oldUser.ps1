function Get-oldUser {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Test-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tN/A"
		return
	}
	query user /server:$Computer
} 

