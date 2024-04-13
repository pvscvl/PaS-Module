function Get-LAPSPW { 
	[CmdletBinding()]
	param (
		[string]$ComputerName
	)
	
	$PASSWORD = (Get-AdmPwdPassword -Computername $ComputerName).Password
	echo -n $PASSWORD | Set-Clipboard
	Get-AdmPwdPassword -Computername $ComputerName | Select-Object ComputerName, Password, ExpirationTimeStamp
}


