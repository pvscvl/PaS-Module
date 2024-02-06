@{
    ModuleVersion = '1.0'
    GUID = '55db66c7-37e0-4a80-9d41-7e5136282c2c'
    Author = 'Pascal Schoofs'
    Description = 'Useful Functions'
    PowerShellVersion = '7.x'
    FunctionsToExport = @('Get-Password', 'Get-OnlineStatus', 'Get-WinRMStatus', 'Get-User', 'Get-WindowsBuild', 'Get-ComputerModel', 'Get-CPUModel', 'Get-GPUModel', 'Get-Diskinformation', 'Get-MemoryCapacity', 'Get-AllMailboxes', 'Get-WinRMStatuswip', 'Get-Userwip')
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
