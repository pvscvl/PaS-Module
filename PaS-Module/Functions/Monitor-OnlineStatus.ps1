function Monitor-OnlineStatus {
	param (
 		[Cmdletbinding()]
     		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
        	[string]$Target
	)

    	$LogPath = "C:\Logs\"
    	$LogFileName = $Target.Replace(".", "_").Replace(":", "_") + ".log"
    	$LogFilePath = Join-Path -Path $LogPath -ChildPath $LogFileName

    	if (-not (Test-Path -Path $LogPath)) {
        	New-Item -Path $LogPath -ItemType Directory | Out-Null
    	}

	$StartTime = Get-Date
	Add-Content -Path $LogFilePath -Value "Ping started at $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))"

	$PreviousStatus = $null
	$PreviousChangeTime = $StartTime

    # Calculate the end time
  	$EndTime = $StartTime.AddHours(72)
   # 	$EndTime = $StartTime.AddMinutes(5)
    	while ((Get-Date) -lt $EndTime) {
        # Test online status
        	$Online = Test-OnlineStatus -Computer $Target

        if ($Online -ne $PreviousStatus) {
            # Status changed
            $ChangeTime = Get-Date
            $Duration = New-TimeSpan -Start $PreviousChangeTime -End $ChangeTime
            if ($PreviousStatus) {
                # Log start of unavailability
                Add-Content -Path $LogFilePath -Value "$Target became unavailable at $($ChangeTime.ToString('yyyy-MM-dd HH:mm:ss')) for $($Duration.ToString())"
            }
            else {
                # Log start of availability
                Add-Content -Path $LogFilePath -Value "$Target became available at $($ChangeTime.ToString('yyyy-MM-dd HH:mm:ss')) for $($Duration.ToString())"
            }
            $PreviousStatus = $Online
            $PreviousChangeTime = $ChangeTime
        }

        # Wait for 5 seconds before testing again
        Start-Sleep -Seconds 1
    }

    # Log the end time
    Add-Content -Path $LogFilePath -Value "Ping ended at $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))"
}

