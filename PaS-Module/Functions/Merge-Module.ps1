function Merge-Module {
        param (
		[string] $MODULENAME,
		[string] $MODULEPATHSRC,
		[string] $MODULEPATHDEST
        )
        $SCRIPTFUNCTIONS = @( Get-ChildItem -Path $MODULEPATHSRC\*.ps1 -ErrorAction SilentlyContinue -Recurse )
        $MODULEPSM = @( Get-ChildItem -Path $MODULEPATHSRC\*.psm1 -ErrorAction SilentlyContinue -Recurse )
        foreach ($FilePath in $SCRIPTFUNCTIONS) {
		$RESULTS = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
		$FUNCTIONS = $RESULTS.EndBlock.Extent.Text
		$FUNCTIONS | Add-Content -Path "$MODULEPATHDEST\$MODULENAME.psm1"
        }
        foreach ($FilePath in $MODULEPSM) {
		$CONTENT = Get-Content $FilePath
		$CONTENT | Add-Content -Path "$MODULEPATHDEST\$MODULENAME.psm1"
        }
        Copy-Item -Path "$MODULEPATHSRC\$MODULENAME.psd1" "$MODULEPATHDEST\$MODULENAME.psd1"
}

function Merge-Modulesource {
        param (
		[string] $ModuleName,
		[string] $ModulePathSource,
		[string] $ModulePathTarget
        )
        $ScriptFunctions = @( Get-ChildItem -Path $ModulePathSource\*.ps1 -ErrorAction SilentlyContinue -Recurse )
        $ModulePSM = @( Get-ChildItem -Path $ModulePathSource\*.psm1 -ErrorAction SilentlyContinue -Recurse )
        foreach ($FilePath in $ScriptFunctions) {
		$Results = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
		$Functions = $Results.EndBlock.Extent.Text
		$Functions | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
        }
        foreach ($FilePath in $ModulePSM) {
		$Content = Get-Content $FilePath
		$Content | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
        }
        Copy-Item -Path "$ModulePathSource\$ModuleName.psd1" "$ModulePathTarget\$ModuleName.psd1"
}