function Get-User {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	
	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tOffline"
		return

	}  
	$OUTPUT = query user /server:$Computer
	$USER = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 1
	$SESSIONSTATUS = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 4
	Write-Host "$Computer User:`t$USER `t($SESSIONSTATUS)"
}