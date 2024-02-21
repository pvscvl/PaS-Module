function Test-ADCredentials {
	[CmdletBinding()]
	Param (
		[string]$UserName,
		[string]$Password
	)
	if (!($UserName) -or !($Password)) {
		Write-Warning 'Test-ADCredential: Please specify both user name and password'
	} else {
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
		$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		if ($user) {
	#		if ($User.AccountLockoutTime -ne $null) {
			if ($null -ne $User.AccountLockoutTime) {
				$User.UnlockAccount()
				Write-Host "Account of $UserName unlocked."
				Write-Host "Account of $User unlocked."
			}
		}
		$VALIDCRED = $DS.ValidateCredentials($UserName, $Password)
		if ($VALIDCRED) {
			Write-Output "Credentials for $UserName were correct."
		} else {
			Write-Warning "Credentials for $UserName were incorrect."
		}
	}
}

