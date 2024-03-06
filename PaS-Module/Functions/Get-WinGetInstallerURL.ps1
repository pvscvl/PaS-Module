function Get-WinGetInstallerURL { 
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$WinGetID
	)
	try { 
 		$DownloadURL =  winget show   $WINGETID | Select-String -Pattern 'Installer-URL:' | ForEach-Object { $_.ToString().Split(': ')[1].Trim() } 
		return $DownloadURL
	} catch {
		return $null
	}
	
}
