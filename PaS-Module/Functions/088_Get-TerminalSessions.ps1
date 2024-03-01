function Get-TerminalSessions {
	[CmdletBinding()]
	$BrokerFQDN = "tkm-sv-ts01.tkm.local"
	try {
		Get-RDUserSession -ConnectionBroker $BrokerFQDN -ErrorAction Ignore | Select-Object hostserver, domainname, username, sessionstate, unifiedsessionid | ft
	}catch {
		Write-Warning "Something went wrong."
	}
}



