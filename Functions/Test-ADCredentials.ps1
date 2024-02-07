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
			if ($user.IsAccountLockedOut()) {
				Write-Host "User $UserName is locked out. Unlocking..."
				$user.UnlockAccount()
				Write-Host "User $UserName has been unlocked."
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