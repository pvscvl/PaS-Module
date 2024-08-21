function Get-Tail {
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [string]$FilePath
	)
    
	# Check if the file exists
	if (-Not (Test-Path $FilePath)) {
	    write-Host ""
	    Write-Host "ERROR: `"$FilePath`" does not exist." -ForegroundColor Red
	} else {
	    Get-Content $FilePath -Wait
	}
    }



    function Tail {
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory=$true)]
	    [ValidateNotNullOrEmpty()]
	    [string]$FilePath
	)
    
	# Check if the file exists
	if (-Not (Test-Path $FilePath)) {
	    write-Host ""
	    Write-Host "ERROR: `"$FilePath`" does not exist." -ForegroundColor Red
	} else {
	    Get-Content $FilePath -Wait
	}
    }



    