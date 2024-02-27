function Get-LockedADAccounts {
	Search-ADAccount -Lockedout | select-object Name, SamAccountName
}
