function Start-WSUSCheckin {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

#	if (-Not (Get-OnlineStatus -Computer $Computer)) {
#                Write-Host "$Computer`tOffline"
#		return
#	}

	if (-Not (Get-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}
	Write-Host "Starting gpupdate..."
	Invoke-Command -ComputerName $Computer -ScriptBlock { gpupdate }

	$targetDir = 'C:\bin'
	$psexecPath = Join-Path $targetDir 'psexec.exe'
	$pstoolsZipUrl = 'https://download.sysinternals.com/files/PSTools.zip'

	if (-Not (Test-Path -Path $psexecPath)) {
		Write-Host "Downloading PSTools.zip..."
		try {
			$zipFilePath = Join-Path $env:TEMP 'PSTools.zip'
			Invoke-WebRequest -Uri $pstoolsZipUrl -OutFile $zipFilePath -ErrorAction Stop
			Write-Host "Extracting PSTools"
			Expand-Archive -Path $zipFilePath -DestinationPath $targetDir -Force
			# Renaming the extracted file to psexec.exe if needed (it might be in a subdirectory inside the zip)
			$extractedPsexecPath = Get-ChildItem -Path $targetDir -Filter 'psexec.exe' -Recurse | Select-Object -First 1
			if ($extractedPsexecPath) {
				Move-Item -Path $extractedPsexecPath.FullName -Destination $psexecPath -Force
			}
			Remove-Item -Path $zipFilePath -Force
			Write-Host "PSTools downloaded and saved to C:\bin"
		} catch {
			Write-Host "Failed to download PSTools.zip. Error: $_.Exception.Message"
			exit 1
		}
	} else {
		Write-Host ""
	}
	Write-Output "$Computer : gpupdate complete. Service WUAUSERV starting."
	Invoke-Command -ComputerName $Computer -ScriptBlock {
		Start-Service wuauserv -Verbose
	}
	
	$Cmd = '$updateSession = new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
	& c:\bin\psexec.exe -s \\$Computer powershell.exe -Command $Cmd

	Write-Host "Waiting 15 seconds for Sync Updates webservice to complete to add to the wuauserv queue so that it can be reported on"
#	Start-Sleep -Seconds 10

	$TOTALSLEEPTIME = 15
	$REFRESHRATE = 1
	$ITERATIONS = $TOTALSLEEPTIME / $REFRESHRATE
	for ($i = 1; $i -le $TOTALSLEEPTIME; $i++) {
		Write-Progress -Activity "Waiting for $TOTALSLEEPTIME seconds" -Status "Time Elapsed: $i seconds" -PercentComplete ($i / $TOTALSLEEPTIME * 100)
		Start-Sleep -Seconds $REFRESHRATE
	}
	

	Write-Output "$Computer : Starting wuauclt /detectnow, /reportnow and /updatenow. Also Starting Usoclient.exe with Parameter ScanInstallWait"


	Invoke-Command -ComputerName $Computer -ScriptBlock {
		wuauclt /detectnow
		(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
		wuauclt /reportnow
		wuauclt /updatenow
		c:\windows\system32\UsoClient.exe ScanInstallWait
	}
}