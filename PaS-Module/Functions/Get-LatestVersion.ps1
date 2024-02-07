function Get-LatestVersion {
	param (
	[string]$REPOSITORY
	)

	if (-not $REPOSITORY) {
		Write-Output "Usage: Get-LatestVersion 'owner/repository' OR 'https://github.com/owner/repository'"
		return
	}

	if ($REPOSITORY -like "https://github.com/*") {
		$REPOSITORY = ($REPOSITORY -split "/")[3..4] -join "/"
	}

	$REPOSITORYNAME = [System.IO.Path]::GetFileName($REPOSITORY)  # Extract the repository name
	$LATESTREPOVERSION = (Invoke-RestMethod -Uri "https://api.github.com/repos/$REPOSITORY/releases/latest").tag_name

	Write-Output "Latest $REPOSITORYNAME version: $LATESTREPOVERSION "
}


