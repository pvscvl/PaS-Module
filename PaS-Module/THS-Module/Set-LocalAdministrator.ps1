function Set-LocalAdministrator {
	[CmdletBinding()]
		param (
        	[string]$ComputerName,
	 	[string]$UserName
		)

     
		Invoke-Command -ComputerName $ComputerName -ScriptBlock {
			param ($UserName)
			Add-LocalGroupMember -Group "Administratoren" -Member $UserName
    		} -ArgumentList $UserName
	}
