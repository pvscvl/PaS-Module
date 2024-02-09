function Start-WSUSCheckin {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	if (-Not (Get-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}
	Write-Host "$Computer`tStarting gpupdate..."
	Invoke-Command -ComputerName $Computer -ScriptBlock { gpupdate }
	Write-Host "$Computer`tgpupdate complete."
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
	Write-Host "$Computer`tStarting WUAUSERV Service..."
	Invoke-Command -ComputerName $Computer -ScriptBlock {
		Start-Service wuauserv -Verbose
	}
	
	$Cmd = '$updateSession = new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
	& c:\bin\psexec.exe -s \\$Computer powershell.exe -Command $Cmd

	Write-Host "Waiting 15 seconds for Sync Updates webservice to complete to add to the wuauserv queue so that it can be reported on"

	$TOTALSLEEPTIME = 15
	$REFRESHRATE = 1
	$ITERATIONS = $TOTALSLEEPTIME / $REFRESHRATE
	for ($i = 1; $i -le $TOTALSLEEPTIME; $i++) {
		Write-Progress -Activity "Waiting for $TOTALSLEEPTIME seconds" -Status "Time Elapsed: $i seconds" -PercentComplete ($i / $TOTALSLEEPTIME * 100)
		Start-Sleep -Seconds $REFRESHRATE
	}
	
	Write-Host "$Computer`tStarting gpupdate..."

	Write-Output "$Computer`tStarting wuauclt /detectnow"
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			wuauclt /detectnow
		}

	Write-Output "$Computer`tStarting ComObject.Microsoft.Update.AutoUpdate.DetectNow"
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
		}

	Write-Output "$Computer`tStarting wuauclt /reportnow"
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			wuauclt /reportnow
		}

	Write-Output "$Computer`tStarting wuauclt /updatenow"
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			wuauclt /updatenow
		}

	Write-Output "$Computer`tStarting c:\windows\system32\UsoClient.exe ScanInstallWait"
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			c:\windows\system32\UsoClient.exe ScanInstallWait
		}

	<# 
		Invoke-Command -ComputerName $Computer -ScriptBlock {
			wuauclt /detectnow
			(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
			wuauclt /reportnow
			wuauclt /updatenow
			c:\windows\system32\UsoClient.exe ScanInstallWait
		}
	#>
}