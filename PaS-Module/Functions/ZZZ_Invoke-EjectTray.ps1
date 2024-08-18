function Invoke-EjectTray {
	[CmdletBinding()]
	param (
        	[string]$Computer
	)

	$command = {
		Add-Type -AssemblyName "Microsoft.VisualBasic"
		$wmp = New-Object -ComObject "WMPlayer.OCX.7"
		$wmp.cdromcollection.item(0).eject()
	}
	
 	Invoke-Command -ComputerName $Computer -ScriptBlock $command
}



function Invoke-EjectDiskTray {
	[CmdletBinding()]
	param (
	    [string]$Computer
	)
    
	$Computer = $Computer.ToUpper()
	$hasDrive = Invoke-Command -ComputerName $Computer -ScriptBlock {
	    $cdDrive = Get-WmiObject -Query "Select * from Win32_CDROMDrive"
	    return $cdDrive -ne $null
	}
    
	if ($hasDrive) {
	    $command = {
		Add-Type -AssemblyName "Microsoft.VisualBasic"
		$wmp = New-Object -ComObject "WMPlayer.OCX.7"
		$wmp.cdromcollection.item(0).eject()
	    }
	    Invoke-Command -ComputerName $Computer -ScriptBlock $command
	    Write-Output "Ejected Diskdrive tray on $Computer."
	} else {
	    Write-Warning "No Diskdrive found on $Computer."
	}
    }
    