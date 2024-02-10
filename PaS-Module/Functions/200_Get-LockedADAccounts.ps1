function Get-LockedADAccounts {
	$lockedOutAccounts = Search-AdAccount -LockedOut
	$selectedProperties = "lastlogondate", "name", "samaccountname"
	if ($lockedOutAccounts.Count -eq 0) {
		Write-Output "No accounts locked out"
	} else {
		$lockedOutAccounts | Select-Object $selectedProperties
	}
}
