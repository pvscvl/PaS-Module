function Get-Gaps_v2 { 
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
		"KTS-MG-NB", "001", "010",
		"KTS-MG-WS", "001", "010",
		"TKM-MG-NB", "001", "040",
		"TKM-MG-WS", "001", "090",
		"TKS-MG-NB", "001", "025",
		"TKS-MG-WS", "001", "010"
	)

	for ($i = 0; $i -lt $hostnameRanges.Length; $i += 3) {
		$prefix = $hostnameRanges[$i]
		$start = [int]$hostnameRanges[$i + 1]
		$end = [int]$hostnameRanges[$i + 2]

		for ($j = $start; $j -le $end; $j++) {
			$computerName = "{0}{1:D3}" -f $prefix, $j
			$computerName = $computerName.ToUpper()  # Convert to uppercase

			$matchNB = $NB -or $Notebook -or $Notebooks
			$matchWS = $WS -or $Workstation -or $Workstations
			$matchANY = $matchNB -or $matchWS

			if (($matchNB -and $prefix -like "*-NB*") -or ($matchWS -and $prefix -like "*-WS*")) {
				$exists = Get-ADComputer -Filter {Name -eq $computerName} -ErrorAction SilentlyContinue
				if ($exists) {
					Write-Host "$computerName" -ForegroundColor Yellow
				} else {
					Write-Host "$computerName" -ForegroundColor Green
				}
			} else {
				if (-not $matchANY) { 
					$exists = Get-ADComputer -Filter {Name -eq $computerName} -ErrorAction SilentlyContinue
					if ($exists) {
						Write-Host "$computerName" -ForegroundColor Yellow
					} else {
						Write-Host "$computerName" -ForegroundColor Green
					}
				}
			}
		}
	}
}
