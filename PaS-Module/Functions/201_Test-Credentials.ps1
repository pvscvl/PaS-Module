function Test-Credentials {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$UserName
	)
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
	$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	if ($UserAccount -ne $null) {
		if ($null -ne $UserAccount.AccountLockoutTime) {
		Write-Warning "Account of $UserName is locked."
		return $null
		}
	}

	$SecurePassword = Read-Host "Enter password for $UserName" -AsSecureString
	if (-not $SecurePassword) {
		Write-Warning 'Test-ADCredential: Password cannot be empty'
		return
	}

	$VALIDCRED = $DS.ValidateCredentials($UserName, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)))

	if ($VALIDCRED) {
		Write-Output "Credentials for $UserName were correct."
	} else {
		Write-Warning "Credentials for $UserName were incorrect."
		$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		if ($user) {
			if ($null -ne $User.AccountLockoutTime) {
				Write-Warning "Account of $UserName is locked out."
				$User.UnlockAccount()
				Write-Host "Account of $UserName unlocked."
			}
		}
	}
}

