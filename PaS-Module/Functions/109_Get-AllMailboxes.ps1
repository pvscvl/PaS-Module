function Get-AllMailboxes {
	$UserCredential = Import-Clixml -Path C:\Users\Pascal\tkm.cred
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://tkm-sv-ex01.tkm.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
	Import-PSSession $Session -DisableNameChecking
		Get-Recipient -ResultSize Unlimited | 
		Select-Object DisplayName,
			@{Name="Type";Expression={$_.RecipientType}},
			PrimarySmtpAddress,
			@{Name="EmailAddresses";Expression={($_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}) -join ","}} |
			Sort-Object DisplayName | 
			Out-GridView
	Remove-PSSession $Session
}