function Test-Credentials {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$UserName
	)
	
	$SecurePassword = Read-Host "Enter password for $UserName" -AsSecureString

	if (-not $SecurePassword) {
		Write-Warning 'Test-ADCredential: Password cannot be empty'
		return
	}

	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
	$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)

	if ($user) {
		if ($User.AccountLockoutTime -ne $null) {
			$User.UnlockAccount()
						Write-Host "Account unlocked"
		}
	}
	$VALIDCRED = $DS.ValidateCredentials($UserName, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)))

	if ($VALIDCRED) {
		Write-Output "Credentials for $UserName were correct."
	} else {
		Write-Warning "Credentials for $UserName were incorrect."
	}
}



if ($User.AccountLockoutTime -ne $null) {
	$User.UnlockAccount()
				Write-Host "Account unlocked"
}