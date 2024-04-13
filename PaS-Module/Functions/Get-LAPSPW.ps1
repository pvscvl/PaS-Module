function Get-LAPSPW { 
	[CmdletBinding()]
	param (
		[string]$ComputerName
	)

	try { 
		$PASSWORD = (Get-AdmPwdPassword -Computername $ComputerName).Password
		echo -n $PASSWORD | Set-Clipboard
		Get-AdmPwdPassword -Computername $ComputerName | Select-Object ComputerName, Password, ExpirationTimeStamp
  	} catch {
   		return $null
     	}
}
