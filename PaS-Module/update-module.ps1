$SCRIPTDIRECTORY = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host ""
Write-Host ""
Write-Host "Script Directory:`t$SCRIPTDIRECTORY"
$FUNCTIONSFOLDER = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "Functions"
Write-Host "Function Folder:`t$FUNCTIONSFOLDER"
$PSM1FILEPATH = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "PaS-Module.psm1"
Write-Host "PSM1-File:`t`t$PSM1FILEPATH"
$PSD1FILEPATH = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "PaS-Module.psd1"
Write-Host "PSD1-File:`t`t$PSD1FILEPATH"
	$scriptFiles = Get-ChildItem -Path $FUNCTIONSFOLDER -Filter "*.ps1"
	$moduleContent = ""

	foreach ($scriptFile in $scriptFiles) {
		$content = Get-Content -Path $scriptFile.FullName -Raw
		$moduleContent += $content + [Environment]::NewLine + [Environment]::NewLine
	}
$moduleContent | Out-File -FilePath $PSM1FILEPATH -Force
Write-Host ""
Write-Host "Done.`t`t$PSM1FILEPATH updated"
Write-Host ""
Write-Host ""

$functionsToExport = (Get-Command -Module (Import-Module $PSM1FILEPATH  -PassThru) | Where-Object {$_.CommandType -eq "Function"}).Name
$values = $functionsToExport

$output = foreach ($value in $values) {
	"'$value',"
}

$output[-1] = $output[-1] -replace ",$"

$WHOLEEXPORTSTRING = "FunctionsToExport = @($output)"
Write-Host "Update PSD1 File."
Write-Host "FunctionsToExport = @($output)"
Write-Output -n $WHOLEEXPORTSTRING | Set-Clipboard
Write-Host ""
Write-Host "`tCopied String to clipboard"
Write-Host ""