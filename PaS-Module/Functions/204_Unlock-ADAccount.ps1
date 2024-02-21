function Unlock-ADAccount {
	param (
		[Parameter(Mandatory = $true)]
		[string]$UserName
	)

	$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	try {
		if ($null -ne $User.AccountLockoutTime) {
			$User.UnlockAccount()
			Write-Host "Account of $UserName unlocked."
			Write-Host "Account of $User unlocked."
		}
	}
	catch {
		Write-Host "Failed to unlock account '$UserName'."
		Write-Host "Error: $_"
	}
}
