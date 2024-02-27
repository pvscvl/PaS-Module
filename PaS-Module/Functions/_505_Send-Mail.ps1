function Send-Mail {
	param(
		[string]$To,
		[string]$Subject,
#		[string]$Body,
		[string]$From = 'noreply@ths-solutions.net',
		[string]$SMTPServer = "10.0.0.109",
		[int]$Port = 825
	)

	$DateFormatPt1 = 'dddd'
	$DateFormatPt2 = 'yyyy-MM-dd'
	$DateFormatPt3 = 'HH:mm:ss'
	$WeekNumber = [System.Globalization.DateTimeFormatInfo]::CurrentInfo.Calendar.GetWeekOfYear($(Get-Date), [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [System.DayOfWeek]::Monday)
	$KW = "KW $WeekNumber"

	$Body = "Hallo zusammen,`r`n`r`nLorem ipsum dolor sit amet, consectetur adipiscing elit.`r`nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua.`r`n`r`n$(Get-Date -Format "$DateFormatPt1")`r`n$(Get-Date -Format "$DateFormatPt2")`r`n$KW`r`n$(Get-Date -Format "$DateFormatPt3")`r`n`r`n`r`nViele Grüße"

	try {
	#	Send-MailMessage -To $To -Subject $Subject -Body $Body -From $From -SmtpServer $SMTPServer -UseSsl -Port $Port -Credential $null -DeliveryNotificationOption OnSuccess
  		Send-MailMessage -To $To -Subject $Subject -Body $Body -From $From -SmtpServer $SMTPServer -UseSsl -Port $Port -DeliveryNotificationOption OnSuccess
		Write-Host "Email sent successfully to $To" -ForegroundColor Green
	} catch {
		Write-Host "Failed to send email: $_" -ForegroundColor Red
	}
}
# Send-Mail -To "recipient@example.com" -Subject "Test Email"



$Body = "Hallo zusammen,`r`n`r`nLorem ipsum dolor sit amet, consectetur adipiscing elit.`r`nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua.`r`n`r`n$(Get-Date -Format "$DateFormatPt1")`r`n$(Get-Date -Format "$DateFormatPt2")`r`n$KW`r`n$(Get-Date -Format "$DateFormatPt3")`r`n`r`n`r`nViele Grüße"
