$FUNCTIONFILES = Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1
foreach ($file in $FUNCTIONFILES) {
	. $file.FullName
}
