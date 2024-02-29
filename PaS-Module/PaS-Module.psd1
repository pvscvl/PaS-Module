@{
	ModuleVersion = '0.1.5'
	GUID = '55db66c7-37e0-4a80-9d41-7e5136282c2c'
	Author = 'Pascal Schoofs'
	Description = 'Useful Functions'
	PowerShellVersion = '7.4.1'
	FunctionsToExport = @('Get-Uptime', 'Get-TerminalSessions', 'Add-LocalAdmin', 'Add-LocalAdminonRemote', 'Convert-ToMacAddress', 'Export-FirefoxProfile', 'Get-ComputerList', 'Get-ComputerModel', 'Get-ComputerUser', 'Get-CPUModel', 'Get-DiskInformation', 'Get-Gaps', 'Get-GPUModel', 'Get-InstalledSoftware', 'Get-IPMILicense', 'Get-LatestVersion', 'Get-LockedADAccounts', 'Get-MACAddress', 'Get-MemoryCapacity', 'Get-oldUser', 'Get-Password', 'Get-WindowsBuild', 'Get-WindowsVersion', 'Import-FirefoxProfile', 'Merge-Module', 'New-ScriptMessage', 'Send-Mail', 'Start-WSUSCheckin', 'sync-WsusClient', 'Test-ADCredentials', 'Test-Credentials', 'Test-DefaultCredentials', 'Test-oldWinRMStatus', 'Test-OnlineStatus', 'Test-WinRMStatus', 'Unlock-ADAccount')
	RootModule = 'PaS-Module.psm1'
	CompatiblePSEditions = @('Core')
	AliasesToExport = @()
	CmdletsToExport = @()
	VariablesToExport = @()
	PrivateData = @{
		PSData = @{
		Tags = @('PowerShell', 'Module', 'Utilities')
		}
	}
}
