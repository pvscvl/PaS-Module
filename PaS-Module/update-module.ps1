$SCRIPTDIRECTORY = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host ""
Write-Host ""
Write-Host "Script Directory:`t$SCRIPTDIRECTORY"
$FUNCTIONSFOLDER = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "Functions"
Write-Host "Function Folder:`t$FUNCTIONSFOLDER"
$MODULEFILE = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "PaS-Module.psm1"
Write-Host "Module-File:`t`t$MODULEFILE"
	$scriptFiles = Get-ChildItem -Path $FUNCTIONSFOLDER -Filter "*.ps1"
	$moduleContent = ""

	foreach ($scriptFile in $scriptFiles) {
		$content = Get-Content -Path $scriptFile.FullName -Raw
		$moduleContent += $content + [Environment]::NewLine + [Environment]::NewLine
	}
$moduleContent | Out-File -FilePath $MODULEFILE -Force
Write-Host ""
Write-Host "Done.`t`t$MODULEFILE updated"
Write-Host ""
Write-Host ""