$SCRIPTDIRECTORY = Split-Path -Parent $MyInvocation.MyCommand.Path
$SCRIPTDIRECTORY 
$FUNCTIONSFOLDER = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "functions"
$FUNCTIONSFOLDER 
$MODULEFILE = Join-Path -Path $SCRIPTDIRECTORY -ChildPath "PaS-Module.psm1"
$MODULEFILE 

# Get all .ps1 files in the functions folder
#	$scriptFiles = Get-ChildItem -Path $FUNCTIONSFOLDER -Filter "*.ps1"

#	$moduleContent = ""


#	foreach ($scriptFile in $scriptFiles) {
#	$content = Get-Content -Path $scriptFile.FullName -Raw
#	$moduleContent += $content + [Environment]::NewLine + [Environment]::NewLine
#	}

#	$moduleContent | Out-File -FilePath $MODULEFILE -Force
