function Get-ComputerList {
	$COMPUTERS = Get-ADComputer -Filter *
	$COMPUTERINFO = @()
	
	foreach ($COMPUTER in $COMPUTERS) {
		$LASTLOGONDATE = Get-ADComputer $COMPUTER -Properties lastLogonDate, Description, DistinguishedName | 
		Select-Object Name, Description, LastLogonDate, 
			@{Name="Location"; Expression={
				$ouComponents = ($_ | Select-Object -ExpandProperty DistinguishedName) -replace '^(CN|OU)=[^,]+,|,DC[^,]+', '' -split '(?<=OU=.+?)(?=OU=)' | ForEach-Object { $_ -replace 'OU=', '' } | ForEach-Object { $_.Trim(',') }    
				[array]::Reverse($ouComponents)
				$ouString = "tkm.local/" + ($ouComponents -join '/')
				$ouString
	    			}
			}
		$COMPUTERINFO += $LASTLOGONDATE
	}
	$COMPUTERINFO | Where-Object { $_.Location -ne $null } | Out-GridView
}
    