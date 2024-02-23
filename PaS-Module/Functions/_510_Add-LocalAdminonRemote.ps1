function Add-LocalAdminonRemote {
	param (
	    [string]$ComputerName,
	    [string]$UserName,
	    [string]$domain = $env:USERDOMAIN
	)
    
	$Credential = Import-Clixml -Path "C:\Users\Pascal\tkm.cred"
    
	if ($ComputerName -match '^\s*$') {
	    throw "Computer name not found: '$ComputerName'"
	}
    
	if ($UserName -match '^\s*$') {
	    throw "SAM not acceptable: '$UserName'"
	}
    
	$null = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
	    param ($UserName, $domain)
	    $group = [ADSI]"WinNT://./Administratoren"
	    $user = [ADSI]"WinNT://$domain/$UserName"
	    $group.Add($user.Path)
	} -ArgumentList $UserName, $domain
    }
    
    # Example usage:
    $computerName = "REMOTE_COMPUTER_NAME"
    $usernameToAdd = "USERNAME_TO_ADD"
    Add-LocalAdmin -comp $computerName -sam $usernameToAdd
    