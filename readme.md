# Powershell Profiles
## Links

* [PowerShell – Single PSM1 file versus multi-file modules](https://evotec.xyz/powershell-single-psm1-file-versus-multi-file-modules/)
* [How to Make Use Of PowerShell Profile Files](https://devblogs.microsoft.com/powershell-community/how-to-make-use-of-powershell-profile-files/)
* [Loading PowerShell Profiles from Other Script Files](https://www.donnfelker.com/loading-powershell-profiles-from-other-script-files/)
* [Splitting my script into multiple .ps1 files: good/bad practice?](https://www.reddit.com/r/PowerShell/comments/hya8o0/splitting_my_script_into_multiple_ps1_files/)
* [Save your PowerShell Profile in your dotfiles repo](https://conradtheprogrammer.medium.com/save-your-powershell-profile-in-your-dotfiles-repo-8ec723532934)


## PaS-Module Structure

```
PaS-Module\
    |- Functions\
    |   |- Get-User.ps1
    |   |- Get-WindowsBuild.ps1
    |   |- <FunctionFile>.ps1
    |- PaS-Module.psm1
    |- PaS-Module.psd1
```


> A module is a .psm1 file. To Import it's usually: `Import-Module .\PaS-Module.psm1` 
> It's Best Practice to name .psd1 and .psm1 the same as the folder
> > If you do it like that, you can just use: `Import-Module .\PaS-Module`


If placed in one of the path's as defined in `$env:PSModulePath` 
you can simply do it like this: `Import-Module PaS-Module`


## PaS-Module.psd1

```
@{
    ModuleVersion = '1.0'
    GUID = '55db66c7-37e0-4a80-9d41-7e5136282c2c'
    Author = 'Pascal Schoofs'
    Description = 'Useful Functions'
    PowerShellVersion = '7.x'
    FunctionsToExport = @('Get-User', 'Get-WindowsBuild')
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
```

## Quote from Reddit regarding Functions and psm1 file

> Personally I keep my function files separate, and I just loop through them with `get-content` and write to my PSM1 file, and update the manifest as necessary. That way I have a psm1 that's fully self-contained, and I can update function files individually. Otherwise it just seems like you're locked into the same version of everything for the life of your code.
> 
> You can add plenty of bells and whistles, but at its core, my process it just this:
> 
> > `get-childitem <functions directory> | get-content | set-content <module.ps1>`
> 
> I iterate through the files to get function names, perform some syntax checks, and check the contents of the psm1 before and after to see if I need to increment the version number, but all that isn't necessary to just get started.



## F7History

Install with:
* `Install-Module -Name "F7History"`

Import with (Put it in $profile):
* `Import-Module -Name "F7History" -ArgumentList  @{Key = "F7"; AllKey = "F8"}`


F7 opens History of Session
F8 opens complete History (including Timestamps)

## Out-ConsoleGridView

Install with:
* `Install-Module microsoft.powershell.consoleguitools`

Usage Example:
* `Get-Service | Out-ConsoleGridView`

* `$SERVICES=Get-Service | Out-ConsoleGridView`

This stores multiple items in a variable



## Lists

- [x] Aufräumen
- [ ] Schlafen
- [ ] Nix tun
- [ ] GARNICHTS TUN
- [ ] verschlafen