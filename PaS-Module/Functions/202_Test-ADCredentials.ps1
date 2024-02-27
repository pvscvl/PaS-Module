<#
.Synopsis
Verify Active Directory credentials
.DESCRIPTION
This function verifies AD User Credentials. The function returns result as boolean.
.NOTES   
Name: Test-ADCredentials
Version: 1.5
.PARAMETER UserName
Samaccountname of AD user account
.PARAMETER Password
Password of AD User account
.EXAMPLE
Test-ADCredentials -username username1 -password Password1!
Test-ADCredentials Toni PWTest#12345
Description:
Verifies if the username and password provided are correct, returning either true or false based on the result
#>

function Test-ADCredentials {
	[CmdletBinding()]
	Param (
		[string]$UserName,
		[string]$Password
	)
	Write-Host "TEST"
	if (!($UserName) -or !($Password)) {
		Write-Warning 'Test-ADCredential: Please specify both user name and password'
	} else {
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
		$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)

		$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)


	if ($ADUserExists -eq "false"){
		Write-Warning "$UserName does not exist"
		return $null
	}
	
	$ADUserLockedOut = (Get-ADuser -Identity $UserName -Properties *).LockedOut
	if ($ADUserLockedOut -eq "true"){
		Write-Warning "Account of $UserName is locked."
		return $null
	}
		$VALIDCRED = $DS.ValidateCredentials($UserName, $Password)
		if ($VALIDCRED) {
			Write-Output "Credentials for $UserName were correct."
		} else {
			Write-Warning "Credentials for $UserName were incorrect."
			$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
			$ADUserLockedOut = (Get-ADuser -Identity $UserName -Properties *).LockedOut
			if ($ADUserLockedOut -eq "true"){
				Write-Warning "Account of $UserName is locked. Unlocking..."
				$UserAccount.UnlockAccount()
				Write-Host "Account of $UserAccount is now unlocked."
			}

		}
	}
}

