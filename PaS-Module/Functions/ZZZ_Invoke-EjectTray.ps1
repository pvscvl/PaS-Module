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
