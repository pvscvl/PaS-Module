function Unlock-ADAccount {
	param (
		[Parameter(Mandatory = $true)]
		[string]$SamAccountName
	)

	try {
		Unlock-ADAccount -Identity $SamAccountName -ErrorAction Stop
		Write-Host "Account '$SamAccountName' has been unlocked."
	}
	catch {
		Write-Host "Failed to unlock account '$SamAccountName'."
		Write-Host "Error: $_"
	}
}