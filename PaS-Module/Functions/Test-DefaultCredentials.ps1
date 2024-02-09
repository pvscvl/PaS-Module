function Test-DefaultCredentials {
	[CmdletBinding()]
	Param (
		[string]$UserName
	)
	if (!$UserName) {
		$UserName = Read-Host "Enter the username"
	}
	$PASSWORDS = @("TKM#12345", "TKS#12345", "KTS#12345", "THS#12345")
	$passwordFound = $false
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
	foreach ($PASSWORD in $PASSWORDS) {
		$isValid = $DS.ValidateCredentials($UserName, $PASSWORD)
			if ($isValid) {
			$PasswordPrefix = $PASSWORD.Substring(0, 3)
			Write-Warning "Password starting with $PasswordPrefix is in use."
			$passwordFound = $true
			break
		}
		$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		if ($User.AccountLockoutTime -ne $null) {
			$User.UnlockAccount()
#			Write-Host "Account unlocked"
		}
	}
	if (-not $passwordFound) {
		Write-Host "User is not using any of the default passwords."
	}
}
