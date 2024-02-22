@{
	ModuleVersion = '0.0.7'
	GUID = '55db66c7-37e0-4a80-9d41-7e5136282c2c'
	Author = 'Pascal Schoofs'
	Description = 'Useful Functions'
	PowerShellVersion = '7.4.1'
	FunctionsToExport = @('Convert-ToMacAddress', 'Get-IPMILicense',  'Get-Gaps', 'Get-ComputerList', 'Merge-Module', 'Export-FirefoxProfile', 'Import-FirefoxProfile', 'Test-Credentials', 'Test-DefaultCredentials', 'Test-ADCredentials', 'Get-Password', 'Test-OnlineStatus', 'Test-WinRMStatus', 'Get-ComputerUser', 'Get-WindowsBuild', 'Get-ComputerModel', 'Get-CPUModel', 'Get-GPUModel', 'Get-DiskInformation', 'Get-MemoryCapacity', 'Get-WindowsVersion', 'Test-oldWinRMStatus', 'Get-oldUser', 'Start-WSUSCheckin')
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
