<#
    .DESCRIPTION
    Pulls a list of all users sessions in a Remote Desktop Server Farm and allows you to select and remove one or many at once.

    .Link
    https://github.com/TheTaylorLee/AdminToolbox
#>

function Remove-TerminalSessions {

    function remove-session {
        [CmdletBinding()]
        Param (
            [Parameter(Position = 0, Mandatory = $true)]$brokerFQDN
        )
		$brokerFQDN = "tkm-sv-ts01.tkm.local"
        $query = Get-RDUserSession -ConnectionBroker $brokerFQDN -ErrorAction Stop |
        Select-Object hostserver, domainname, username, sessionstate, unifiedsessionid  |
        Out-GridView -PassThru -Title 'Select a User Session or sessions to Remove'
        foreach ($prompt in $query) {
            $hostserver = $prompt.hostserver
            $SessionID = $prompt.unifiedsessionid
            $user = $prompt.username
            Write-Host "Removing $user session from $hostserver"
            rwinsta.exe $sessionID /SERVER:$hostserver
        }
    }

    try {
    #    $BrokerFQDN = (Get-WmiObject win32_computersystem).DNSHostName + "." + (Get-WmiObject win32_computersystem).Domain
	#	$BrokerFQDN = "tkm-sv-ts01" + "." + (Get-WmiObject win32_computersystem).Domain
		$BrokerFQDN = "tkm-sv-ts01.tkm.local"
        remove-session -brokerFQDN $BrokerFQDN
    }
    catch {
        $BrokerFQDN = Read-Host 'Specify the FQDN of the ConnectionBroker ex: Company-AZ-BKR01.domain.com'
        remove-session -brokerFQDN $BrokerFQDN
    }
}


