@{
	ModuleVersion = '0.0.9'
	GUID = '55db66c7-37e0-4a80-9d41-7e5136282c2c'
	Author = 'Pascal Schoofs'
	Description = 'Useful Functions'
	PowerShellVersion = '7.4.0'
	FunctionsToExport = @('Export-FirefoxProfile', 'Import-FirefoxProfile', 'Test-Credentials', 'Test-DefaultCredentials', 'Test-ADCredentials', 'Get-Password', 'Get-OnlineStatus', 'Get-WinRMStatus', 'Get-User', 'Get-WindowsBuild', 'Get-ComputerModel', 'Get-CPUModel', 'Get-GPUModel', 'Get-Diskinformation', 'Get-MemoryCapacity', 'Get-AllMailboxes', 'Get-WindowsVersion', 'Get-oldWinRMStatus', 'Get-oldUser', 'Start-WSUSCheckin')
	RootModule = 'PaS-Module.psm1'
	CompatiblePSEditions = @('Desktop')
	AliasesToExport = @()
	CmdletsToExport = @()
	VariablesToExport = @()
	PrivateData = @{
		PSData = @{
		Tags = @('PowerShell', 'Module', 'Utilities')
		ReleaseNotes = 'Initial release as module'
		}
	}
}
