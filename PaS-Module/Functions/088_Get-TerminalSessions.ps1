function Get-TerminalSessions {

	$brokerFQDN = "tkm-sv-ts01.tkm.local"
    try {
		Get-RDUserSession -ConnectionBroker $brokerFQDN -ErrorAction Ignore | Select-Object hostserver, domainname, username, sessionstate, unifiedsessionid | ft
    }
    catch {
        Write-Warning "Error"
    }
}



