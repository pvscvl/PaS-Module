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

	$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	if ($UserAccount -ne $null) {
		if ($null -ne $UserAccount.AccountLockoutTime) {
		Write-Warning "Account of $UserName is locked."
		return $null
		}
	}


	foreach ($PASSWORD in $PASSWORDS) {
		$isValid = $DS.ValidateCredentials($UserName, $PASSWORD)
			if ($isValid) {
				$PasswordPrefix = $PASSWORD.Substring(0, 3)
				Write-Warning "${PasswordPrefix}-default password is in use."
				$passwordFound = $true
				break
			} else {
				Write-Warning "Credentials for $UserName were incorrect."
				$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	
				if ($UserAccount -ne $null) {
					if ($null -ne $UserAccount.AccountLockoutTime) {
						Write-Warning "Account of $UserName is locked."
						$UserAccount.UnlockAccount()
						Write-Host "Account of $UserAccount unlocked."
					}
				}
			}
	}		
	#	$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	#	if ($User.AccountLockoutTime -ne $null) {
	#	if ($null -ne $User.AccountLockoutTime) {
	#			$User.UnlockAccount()
	#			Write-Host "Account of $UserName unlocked."
	#			Write-Host "Account of $User unlocked."
	#	}
	
	if (-not $passwordFound) {
		Write-Host "$UserName is not using any of the default passwords."
	}
}

