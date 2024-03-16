function Get-ComputerUser {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	
	if (-Not (Test-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tN/A"
		return
	}  
	
	$OUTPUT = query user /server:$Computer
	$USER = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 1
	$SESSIONSTATUS = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 4
 	$Computer = $Computer.ToUpper()
	Write-Host "$Computer`tUser: $USER `t($SESSIONSTATUS)"
}

