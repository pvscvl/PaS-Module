function Get-Gaps { 
	[CmdletBinding()]
	param (
        	[switch]$NB,
        	[switch]$WS,
        	[switch]$Notebook,
        	[switch]$Notebooks,
        	[switch]$Workstation,
        	[switch]$Workstations
	)

	$hostnameRanges = @(
        	"KTS-MG-NB", "001", "004",
        	"KTS-MG-WS", "001", "006",
        	"TKM-MG-NB", "001", "035",
        	"TKM-MG-WS", "001", "085",
        	"TKS-MG-NB", "001", "022",
        	"TKS-MG-WS", "001", "004"
	)
    
	$missingComputers = @()

	for ($i = 0; $i -lt $hostnameRanges.Length; $i += 3) {
        	$prefix = $hostnameRanges[$i]
        	$start = [int]$hostnameRanges[$i + 1]
        	$end = [int]$hostnameRanges[$i + 2]

        	for ($j = $start; $j -le $end; $j++) {
                	$computerName = "{0}{1:D3}" -f $prefix, $j

        	    	$matchNB = $NB -or $Notebook -or $Notebooks
        	    	$matchWS = $WS -or $Workstation -or $Workstations
			$matchANY = $matchNB -or $matchWS

        		if (($matchNB -and $prefix -like "*-NB*") -or ($matchWS -and $prefix -like "*-WS*")) {
        	        	if (-not (Get-ADComputer -Filter {Name -eq $computerName})) {
        	        		$missingComputers += $computerName
        	        	}
        		} else {
				if (-not $matchANY) { 
					if (-not (Get-ADComputer -Filter {Name -eq $computerName})) {
						$missingComputers += $computerName
			    		}
		    		}
			}
        	}
	}
	if ($missingComputers) {
        	Write-Host "Unused Hostnames: "
        	$missingComputers
    	}
}
