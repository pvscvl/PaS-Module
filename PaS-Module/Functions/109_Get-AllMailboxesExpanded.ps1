function Get-AllMailInformationss {
	$UserCredential = Import-Clixml -Path C:\Users\Pascal\tkm.cred
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://tkm-sv-ex01.tkm.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
	Import-PSSession $Session -DisableNameChecking
	
	$Mailboxes = Get-Recipient -ResultSize Unlimited
    
	$MailboxPermissions = foreach ($Mailbox in $Mailboxes) {
	    $MailboxInfo = Get-Mailbox $Mailbox.Identity
    
	    $FullAccess = Get-MailboxPermission -Identity $MailboxInfo.Identity -ResultSize Unlimited | Where-Object { $_.AccessRights -eq "FullAccess" -and $_.IsInherited -eq $false } | Select-Object @{Name="User";Expression={$_.User}},@{Name="AccessRights";Expression={$_.AccessRights}}
	    $SendAs = Get-ADPermission -Identity $MailboxInfo.Identity | Where-Object { $_.ExtendedRights -like "Send-As" -and $_.IsInherited -eq $false } | Select-Object @{Name="User";Expression={$_.User}},@{Name="ExtendedRights";Expression={$_.ExtendedRights}}
    
	    foreach ($Access in $FullAccess) {
		$Access | Add-Member -MemberType NoteProperty -Name "Type" -Value "Full Access"
		$Access | Add-Member -MemberType NoteProperty -Name "Mailbox" -Value $MailboxInfo.PrimarySmtpAddress
		$Access
	    }
    
	    foreach ($Access in $SendAs) {
		$Access | Add-Member -MemberType NoteProperty -Name "Type" -Value "Send As"
		$Access | Add-Member -MemberType NoteProperty -Name "Mailbox" -Value $MailboxInfo.PrimarySmtpAddress
		$Access
	    }
	}
    
	$MailboxPermissions | Select-Object Mailbox, User, Type, AccessRights, ExtendedRights | Sort-Object Mailbox, User | Out-GridView
    
	Remove-PSSession $Session
    }
    