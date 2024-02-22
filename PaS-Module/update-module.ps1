$SCRIPTDIRECTORY = Split-Path -Parent $MyInvocation.MyCommand.Path
$FUNCTIONSFOLDER = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "Functions"
$MODULEFILE = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "PaS-Module.psm1"

	$scriptFiles = Get-ChildItem -Path $FUNCTIONSFOLDER -Filter "*.ps1"
	$moduleContent = ""

	foreach ($scriptFile in $scriptFiles) {
		$content = Get-Content -Path $scriptFile.FullName -Raw
		$moduleContent += $content + [Environment]::NewLine + [Environment]::NewLine
	}
$moduleContent | Out-File -FilePath $MODULEFILE -Force
