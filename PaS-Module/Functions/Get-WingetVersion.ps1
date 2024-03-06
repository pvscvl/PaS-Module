 function Get-WinGetVersion { 
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$WinGetID
   		[switch]$Trim
	)
	try { 
 		$Version =  winget show   $WINGETID | Select-String -Pattern 'Version:' | ForEach-Object { $_.ToString().Split(': ')[1].Trim() } 
        	if ($Trim) {
             		$Version = $Version -replace '\.'
	      	}
		return $Version
	} catch {
		return $null
	}
	
}
