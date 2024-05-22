function New-ScriptMessage {
	<#
		.SYNOPSIS
			Helper Function to show default message used in VERBOSE/DEBUG/WARNING
	
		.DESCRIPTION
			Helper Function to show default message used in VERBOSE/DEBUG/WARNING
			and... HOST in some case.
			This is helpful to standardize the output messages
	
		.PARAMETER Message
			Specifies the message to show
	
		.PARAMETER Block
			Specifies the Block where the message is coming from.
	
		.PARAMETER DateFormat
			Specifies the format of the date.
			Default is 'yyyy\/MM\/dd HH:mm:ss:ff' For example: 2016/04/20 23:33:46:78
	
		.PARAMETER FunctionScope
			Valid values are "Global", "Local", or "Script", or a number relative to the current scope (0 through the number of scopes, where 0 is the current scope and 1 is its parent). "Local" is the default
			See also: About_scopes https://technet.microsoft.com/en-us/library/hh847849.aspx
			Example:
			0 is New-ScriptMessage
			1 is the function calling New-ScriptMessage
			2 is for example the script/function calling the function which call New-ScriptMessage
			etc...
	
		.EXAMPLE
			New-ScriptMessage "Neue Nachricht"
			[2024-02-23 11:58:21] Neue Nachricht
	
		.EXAMPLE
			New-ScriptMessage "Neue Nachricht" "PaS-Module"
			[2024-02-23 11:58:39][PaS-Module] Neue Nachricht
	
		.EXAMPLE
			New-ScriptMessage -Message "Francois-Xavier" -Block PROCESS -Verbose -FunctionScope 0
			[2016/04/20 23:33:46:78][New-ScriptMessage][PROCESS] Francois-Xavier
	
		.EXAMPLE
			New-ScriptMessage -message "Connected"
			if the function is just called from the prompt you will get the following output
			[2015/03/14 17:32:53:62] Connected
	
		.EXAMPLE
			New-ScriptMessage -message "Connected to $Computer" -FunctionScope 1
			If the function is called from inside another function,
			It will show the name of the function.
			[2015/03/14 17:32:53:62][Get-Something] Connected
	
		.NOTES
			Test
		.LINK
			Test
	#>
	
		[CmdletBinding()]
		[OutputType([string])]
		param
		(
			[String]$Message,
			[String]$Block,
			[String]$DateFormat = 'yyyy-MM-dd HH:mm:ss',
			$FunctionScope = "1"
		)
	
		PROCESS {
			$DateFormat = Get-Date -Format $DateFormat
			$MyCommand = (Get-Variable -Scope $FunctionScope -Name MyInvocation -ValueOnly).MyCommand.Name
			IF ($MyCommand) {
				$String = "[$DateFormat][$MyCommand]"
			} #IF
			ELSE {
				$String = "[$DateFormat]"
			} #Else
	
			IF ($PSBoundParameters['Block']) {
				$String += "[$Block]"
			}
			Write-Output "$String $Message"
		} #Process
	}
	
	function sync-WsusClient {
	<#
		.SYNOPSIS
		Function to force the given computer(s) to check for updates and check in with the WSUS server
		
		.DESCRIPTION
		Connects to computer list over WinRM (PsSession) and forces it to check for updates and report to its WSUS server
		Default if no computers listed is to use localhost
		Meant to run against many computers and get quick results
		
		.PARAMETER ComputerName
		A string list of computer names against which to run this sync command
		
		.PARAMETER Credential
		A "pscredential" that will be used to connect to the remote computer(s)
		
		.EXAMPLE
		Sync-WsusClient
		"localhost - Done!"
		
		.EXAMPLE
		Sync-WsusClient server1, server2, server3, server4
		"server2 - Done!"
		"server1 - Done!"
		"server4 - Done!"
		"server3 - Done!"
		
		.EXAMPLE
		Sync-WsusClient server1, server2 -Credential admin
		(enter your credential and then...)
		"server2 - Done!"
		"server1 - Done!"
		
		.NOTES
		Here's one place where it came from: http://pleasework.robbievance.net/howto-force-really-wsus-clients-to-check-in-on-demand/
		Roger P Seekell, (2019), 9-13-2019
	#>
	
		Param(
			[Parameter(ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[string[]]$ComputerName = 'localhost',
			[pscredential]$Credential = $null
		)
	
		process {
			$scriptBlock = {
				try {
					$updateSession = New-Object -com "Microsoft.Update.Session"
					$null = $updateSession.CreateUpdateSearcher().Search($criteria).UPdates #I don't want to see them
					wuauclt /reportnow
					"$env:computername - Done!"
				} catch {
					Write-Error "Sync unsuccessful on $env:computername : $_"
				}
			}#end script block
	
			$splat = @{"ComputerName" = $ComputerName; "ScriptBlock" = $scriptBlock}
	
			if ($Credential -ne $null) {
				$splat += @{"Credential" = $Credential}
			}
		Invoke-Command @splat #run with the two or three parameters above
		}#end process
	}
	
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
			Send-MailMessage -To $To -Subject $Subject -Body $Body -From $From -SmtpServer $SMTPServer -UseSsl -Port $Port -Credential $null -DeliveryNotificationOption OnSuccess
			Write-Host "Email sent successfully to $To" -ForegroundColor Green
		} catch {
			Write-Host "Failed to send email: $_" -ForegroundColor Red
		}
	}
	# Send-Mail -To "recipient@example.com" -Subject "Test Email"
	
	
	
	$Body = "Hallo zusammen,`r`n`r`nLorem ipsum dolor sit amet, consectetur adipiscing elit.`r`nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua.`r`n`r`n$(Get-Date -Format "$DateFormatPt1")`r`n$(Get-Date -Format "$DateFormatPt2")`r`n$KW`r`n$(Get-Date -Format "$DateFormatPt3")`r`n`r`n`r`nViele Grüße"
	
	
	function Add-LocalAdmin {
		<#
		.SYNOPSIS
		Adds User to Administrators Group on Remote Device
		
		.DESCRIPTION
		bla
		
		.EXAMPLE
		$computerName = "REMOTE_COMPUTER_NAME"
		$usernameToAdd = "USERNAME_TO_ADD"
		Add-LocalAdmin -comp $computerName -sam $usernameToAdd
	#>
		param (
			[string]$ComputerName,
			[string]$UserName,
			[string]$domain = $env:USERDOMAIN
		)
	
		$Credential = Import-Clixml -Path "C:\Users\Pascal\tkm.cred"
	
		if ($ComputerName -match '^\s*$') {
			throw "Computer name not found: '$ComputerName'"
		}
	
		if ($UserName -match '^\s*$') {
			throw "SAM not acceptable: '$UserName'"
		}
	
		$null = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
			param ($UserName, $domain)
			$group = [ADSI]"WinNT://./Administratoren"
			$user = [ADSI]"WinNT://$domain/$UserName"
			$group.Add($user.Path)
		} -ArgumentList $UserName, $domain
	}
	
	
	
	function Get-InstalledSoftware {
		    <# 
		    .SYNOPSIS 
		    Function returns installed applications. 
		 
		    .DESCRIPTION 
		    Function returns installed applications. 
		    Such information is retrieved from registry keys 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\', 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'. 
		 
		    .PARAMETER ComputerName 
		    Name of the remote computer where you want to run this function. 
		 
		    .PARAMETER AppName 
		    (optional) Name of the application(s) to look for. 
		    It can be just part of the app name. 
		 
		    .PARAMETER DontIgnoreUpdates 
		    Switch for getting Windows Updates too. 
		 
		    .PARAMETER Property 
		    What properties of the registry key should be returned. 
		 
		    Default is 'DisplayVersion', 'UninstallString'. 
		 
		    DisplayName will be always returned no matter what. 
		 
		    .PARAMETER Ogv 
		    Switch for getting results in Out-GridView. 
		 
		    .EXAMPLE 
		    Get-InstalledSoftware 
		 
		    Show all installed applications on local computer 
		 
		    .EXAMPLE 
		    Get-InstalledSoftware -DisplayName 7zip 
		 
		    Check whether application with name 7zip is installed on local computer. 
		 
		    .EXAMPLE 
		    Get-InstalledSoftware -DisplayName 7zip -Property Publisher, Contact, VersionMajor -Ogv 
		 
		    Check whether application with name 7zip is installed on local computer and output results to Out-GridView with just selected properties. 
		 
		    .EXAMPLE 
		    Get-InstalledSoftware -ComputerName PC01 
		 
		    Show all installed applications on computer PC01. 
		    #>
		
		    [CmdletBinding()]
		    param(
		        [ArgumentCompleter( {
		                param ($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
		
		                Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | % { try { Get-ItemPropertyValue -Path $_.pspath -Name DisplayName -ErrorAction Stop } catch { $null } } | ? { $_ -like "*$WordToComplete*" } | % { "'$_'" }
		            })]
		        [string[]] $appName,
		
		        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		        [string[]] $computerName,
		
		        [switch] $dontIgnoreUpdates,
		
		        [ValidateNotNullOrEmpty()]
		        [ValidateSet('AuthorizedCDFPrefix', 'Comments', 'Contact', 'DisplayName', 'DisplayVersion', 'EstimatedSize', 'HelpLink', 'HelpTelephone', 'InstallDate', 'InstallLocation', 'InstallSource', 'Language', 'ModifyPath', 'NoModify', 'NoRepair', 'Publisher', 'QuietUninstallString', 'UninstallString', 'URLInfoAbout', 'URLUpdateInfo', 'Version', 'VersionMajor', 'VersionMinor', 'WindowsInstaller')]
		        [string[]] $property = ('DisplayName', 'DisplayVersion', 'UninstallString'),
		
		        [switch] $ogv
		    )
		
		    PROCESS {
		        $scriptBlock = {
		            param ($Property, $DontIgnoreUpdates, $appName)
		
		            # where to search for applications
		            $RegistryLocation = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\', 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
		
		            # define what properties should be outputted
		            $SelectProperty = @('DisplayName') # DisplayName will be always outputted
		            if ($Property) {
		                $SelectProperty += $Property
		            }
		            $SelectProperty = $SelectProperty | select -Unique
		
		            $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $env:COMPUTERNAME)
		            if (!$RegBase) {
		                Write-Error "Unable to open registry on $env:COMPUTERNAME"
		                return
		            }
		
		            foreach ($RegKey in $RegistryLocation) {
		                Write-Verbose "Checking '$RegKey'"
		                foreach ($appKeyName in $RegBase.OpenSubKey($RegKey).GetSubKeyNames()) {
		                    Write-Verbose "`t'$appKeyName'"
		                    $ObjectProperty = [ordered]@{}
		                    foreach ($CurrentProperty in $SelectProperty) {
		                        Write-Verbose "`t`tGetting value of '$CurrentProperty' in '$RegKey$appKeyName'"
		                        $ObjectProperty.$CurrentProperty = ($RegBase.OpenSubKey("$RegKey$appKeyName")).GetValue($CurrentProperty)
		                    }
		
		                    if (!$ObjectProperty.DisplayName) {
		                        # Skipping. There are some weird records in registry key that are not related to any app"
		                        continue
		                    }
		
		                    $ObjectProperty.ComputerName = $env:COMPUTERNAME
		
		                    # create final object
		                    $appObj = New-Object -TypeName PSCustomObject -Property $ObjectProperty
		
		                    if ($appName) {
		                        $appNameRegex = $appName | % {
		                            [regex]::Escape($_)
		                        }
		                        $appNameRegex = $appNameRegex -join "|"
		                        $appObj = $appObj | ? { $_.DisplayName -match $appNameRegex }
		                    }
		
		                    if (!$DontIgnoreUpdates) {
		                        $appObj = $appObj | ? { $_.DisplayName -notlike "*Update for Microsoft*" -and $_.DisplayName -notlike "Security Update*" }
		                    }
		
		                    $appObj
		                }
		            }
		        }
		
		        $param = @{
		            scriptBlock  = $scriptBlock
		            ArgumentList = $property, $dontIgnoreUpdates, $appName
		        }
		        if ($computerName) {
		            $param.computerName = $computerName
		            $param.HideComputerName = $true
		        }
		
		        $result = Invoke-Command @param
		
		        if ($computerName) {
		            $result = $result | select * -ExcludeProperty RunspaceId
		        }
		    }
		
		    END {
		        if ($ogv) {
		            $comp = $env:COMPUTERNAME
		            if ($computerName) { $comp = $computerName }
		            $result | Out-GridView -PassThru -Title "Installed software on $comp"
		        } else {
		            $result
		        }
		    }
		}
		
		
	
	function Test-OnlineStatus {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
		$ping = Test-Connection -ComputerName $Computer -Count 1 -Quiet
		return $ping
	}
	
	
	
	
	function Test-WinRMStatus {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
		#	return (Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) -ne $null
			return $null -ne (Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) 
		} else {
			return $false
		}
	}
	
	
	
	
	function Test-oldWinRMStatus{
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		$wsmanResult = Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue
		if ($wsmanResult) {
			return $true
		}
		else {
			return $false
		}
	}
	
	
	
	function Get-Password {
		function Get-RandomCharacters($LENGTH, $CHARACTERS) {
			$RANDOM_INDICES = 1..$LENGTH | ForEach-Object { Get-Random -Maximum $CHARACTERS.LENGTH }
			$PRIVATE:OFS = ""
			return [String]$CHARACTERS[$RANDOM_INDICES]
		}
	
		$UPPERCASE_CHARS = 'ABCDEFGHKLMNPRQSTUVWXYZ'
		$LOWERCASE_CHARS = 'abcdefghikmnoprstuvwxyz'
		$NUMERIC_CHARS = '1234567890'
	
		$PASSWORD_PART1 = Get-RandomCharacters -LENGTH 4 -CHARACTERS $UPPERCASE_CHARS
		$PASSWORD_PART2 = Get-RandomCharacters -LENGTH 4 -CHARACTERS $LOWERCASE_CHARS
		$PASSWORD_PART3 = Get-RandomCharacters -LENGTH 4 -CHARACTERS $NUMERIC_CHARS
	
		$GENERATED_PASSWORD = "$PASSWORD_PART1-$PASSWORD_PART2#$PASSWORD_PART3"
	
		echo -n $GENERATED_PASSWORD | Set-Clipboard
		Write-Host ""
		Write-Host ""
		Write-Host "$GENERATED_PASSWORD"
		Write-Host ""
	}
	
function Get-Uptime {
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)
	
	if (-Not (Test-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}
	
	$LastBootUpTime = (Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem).LastBootUpTime
	$Uptime = New-TimeSpan -Start $LastBootUpTime -End (Get-Date)
	Write-Host "$Computer - System Uptime:`t $($Uptime.Days) days $($Uptime.Hours) hours $($Uptime.Minutes) minutes"
}
	
	function Get-LatestVersion {
		param (
		[string]$REPOSITORY
		)
	
		if (-not $REPOSITORY) {
			Write-Output "Usage: Get-LatestVersion 'owner/repository' OR 'https://github.com/owner/repository'"
			return
		}
	
		if ($REPOSITORY -like "https://github.com/*") {
			$REPOSITORY = ($REPOSITORY -split "/")[3..4] -join "/"
		}
	
		$REPOSITORYNAME = [System.IO.Path]::GetFileName($REPOSITORY)  # Extract the repository name
		$LATESTREPOVERSION = (Invoke-RestMethod -Uri "https://api.github.com/repos/$REPOSITORY/releases/latest").tag_name
		Write-Output "Latest $REPOSITORYNAME version: $LATESTREPOVERSION "
	}
	
	
	
	function Export-FirefoxProfile {
		param (
			[switch]$VERBOSE
		)
	
		$CURRENTDIRECTORY = Get-Location
		$TEMP_FOLDER_PATH = "C:\temp"
		$BACKUP_PATH = "Q:\"
		$7ZIP64EXE = "C:\Program Files\7-Zip\7z.exe"
		$7ZIP32EXE = "C:\Program Files (x86)\7-Zip\7z.exe"
		$FIREFOX32EXE = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
		$FIREFOX64EXE = "C:\Program Files\Mozilla Firefox\firefox.exe"
		$USER_PROFILE_PATH = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
		$FIREFOX_PROFILES_PATH = Join-Path $USER_PROFILE_PATH "AppData\Roaming\Mozilla\Firefox\Profiles"
		$LATEST_PROFILE = Get-ChildItem $FIREFOX_PROFILES_PATH | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	
		Write-Host "Closing Firefox processes ..."
		$FIREFOX_PROCESSES = Get-Process -Name firefox -ErrorAction SilentlyContinue
		If ($VERBOSE) { Write-Host "Retrieved Firefox processes." }
	
		if ($FIREFOX_PROCESSES) {
			foreach ($PROCESS in $FIREFOX_PROCESSES) {
				$PROCESS.CloseMainWindow() | Out-Null
					If ($VERBOSE) { Write-Host "" }
					If ($VERBOSE) { Write-Host "Requested to close Firefox process ID $($PROCESS.Id)." }
				$PROCESS.WaitForExit(10) | Out-Null
					If ($VERBOSE) { Write-Host "Waited for process ID $($PROCESS.Id) to exit." }
	
				if (!$PROCESS.HasExited) {
					$PROCESS | Stop-Process -Force | Out-Null
					If ($VERBOSE) { Write-Host "Forcefully stopped process ID $($PROCESS.Id)." }
				}
			}
		}
	    
		Write-Host "Exporting Firefox Profile to vol Q."
		If ($VERBOSE) { Write-Host "User profile path: $USER_PROFILE_PATH" }
		If ($VERBOSE) { Write-Host "Firefox profiles path: $FIREFOX_PROFILES_PATH" }
	    
		if (-Not (Test-Path -Path $BACKUP_PATH -PathType Container)) {
			New-Item -Path $BACKUP_PATH -ItemType Directory -Force | Out-Null
			If ($VERBOSE) { Write-Host "Created backup path: $BACKUP_PATH" }
		}
	    
		if (-Not (Test-Path -Path $TEMP_FOLDER_PATH -PathType Container)) {
			New-Item -Path $TEMP_FOLDER_PATH -ItemType Directory -Force | Out-Null
				If ($VERBOSE) { Write-Host "Created temporary folder path: $TEMP_FOLDER_PATH" }
		}
	
		if ($LATEST_PROFILE -ne $null) {
			$LATEST_PROFILE_PATH = $LATEST_PROFILE.FullName
				If ($VERBOSE) { Write-Host "Latest profile path: $LATEST_PROFILE_PATH" }
			Set-Location -Path $LATEST_PROFILE_PATH | Out-Null
				If ($VERBOSE) { Write-Host "Changed location to the latest profile path." }
				If ($VERBOSE) { Write-Host "LATEST_PROFILE_PATH: $LATEST_PROFILE_PATH" }
	
			$BACKUP_FILE_NAME = "FirefoxProfile_$($LATEST_PROFILE.Name)_$(Get-Date -Format 'yyyyMMdd').zip"
			$BACKUP_FILE_PATH = Join-Path $TEMP_FOLDER_PATH $BACKUP_FILE_NAME
	
				If ($VERBOSE) { Write-Host "Backup file name and path set." }
				If ($VERBOSE) { Write-Host "BACKUP_FILE_NAME: $BACKUP_FILE_NAME" }
				If ($VERBOSE) { Write-Host "BACKUP_FILE_PATH: $BACKUP_FILE_PATH" }
	
			if (Test-Path $7ZIP64EXE) {
				If ($VERBOSE) { Write-Host "Using 7Zip (64Bit) to compress profile." }
				& $7ZIP64EXE a -tzip -mx0 $BACKUP_FILE_PATH .\* | Out-Null 
			} elseif (Test-Path $7ZIP32EXE) {
				If ($VERBOSE) { Write-Host "Using 7Zip (32Bit) to compress profile." }
				& $7ZIP32EXE a -tzip -mx0 $BACKUP_FILE_PATH .\* | Out-Null
			} else {
					If ($VERBOSE) { Write-Host "Using native windows Compress-Archive function to compress profile." }
				Compress-Archive -Path .\* -DestinationPath $BACKUP_FILE_PATH -CompressionLevel NoCompression
			}
	    
		If ($VERBOSE) { Write-Host "Created zip archive of the profile." }
			Copy-Item -Path $BACKUP_FILE_PATH -Destination $BACKUP_PATH -Force
			Remove-Item -Path $BACKUP_FILE_PATH -Force
	    
		Set-Location -Path $CURRENTDIRECTORY | Out-Null
			If ($VERBOSE) { Write-Host "Changed location back to $CURRENTDIRECTORY " }
		} else {
			Write-Host "No Firefox profile found in the specified path."
		}
	    
		if (Test-Path $FIREFOX64EXE) {
			Start-Process -FilePath $FIREFOX64EXE | Out-Null
				If ($VERBOSE) { Write-Host "Started 64-bit Firefox." }
		} 
		elseif (Test-Path $FIREFOX32EXE) {
			Start-Process -FilePath $FIREFOX32EXE | Out-Null
				If ($VERBOSE) { Write-Host "Started 32-bit Firefox." }
		} else {
		Write-Host "Firefox not found in the expected locations."
		}
	
		Write-Host "Firefox profile backup complete. Firefox has been restarted."
	}
	
	
	
	function Import-FirefoxProfile {
		param (
			[switch]$VERBOSE
		)
	
		$sourcePath = "Q:\"
		$backupFileNamePattern = "FirefoxProfile_*.zip"
		$tempPath = "C:\temp"
		$firefoxProfilePath = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
	
		$firefoxProcesses = Get-Process -Name firefox -ErrorAction SilentlyContinue
		if ($firefoxProcesses) {
			foreach ($process in $firefoxProcesses) {
				$process.CloseMainWindow() | Out-Null
				$process.WaitForExit(10) | Out-Null
				if (!$process.HasExited) {
					$process | Stop-Process -Force | Out-Null
				}
			}
		}
	    
		$latestBackup = Get-ChildItem -Path $sourcePath -Filter $backupFileNamePattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
		if ($latestBackup -ne $null) {
			$tempFilePath = Join-Path $tempPath $latestBackup.Name
			Copy-Item -Path $latestBackup.FullName -Destination $tempFilePath -Force
	    
			$firefoxProfiles = Get-ChildItem -Path $firefoxProfilePath -Directory
	    
			$latestProfile = $firefoxProfiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	    
			if ($latestProfile -ne $null) {
			$profileFolderPath = $latestProfile.FullName
	    
			Get-ChildItem -Path $profileFolderPath | Remove-Item -Force -Recurse
	    
			Expand-Archive -Path $tempFilePath  -DestinationPath $profileFolderPath -Force | Out-Null
	    
			Remove-Item -Path $tempFilePath -Force
	    
			Write-Host "Firefox profile imported from backup."
	
			$firefox64Path = "C:\Program Files\Mozilla Firefox\firefox.exe"
			if (Test-Path $firefox64Path) {
				Start-Process -FilePath $firefox64Path | Out-Null
			} else {
				$firefox32Path = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
				if (Test-Path $firefox32Path) {
					Start-Process -FilePath $firefox32Path | Out-Null
				    } else {
					Write-Host "Firefox not found in the expected locations."
				}
			}
			} else {
			Write-Host "No Firefox profile found in the specified directory."
			}
		} else {
			Write-Host "No Firefox profile backup found in the specified path."
		}
	}
	
	
	
	function Get-ComputerUser {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
		
		if (-Not (Test-OnlineStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}  
		
		$OUTPUT = query user /server:$Computer
		$USER = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 1
		$SESSIONSTATUS = ($OUTPUT -split "`r`n")[1] -split "\s+" | Select-Object -Index 4
		Write-Host "$Computer`tUser: $USER `t($SESSIONSTATUS)"
	}
	
	
	
	function Get-oldUser {
		param (
			[Parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-OnlineStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
		query user /server:$Computer
	} 
	
	
	
	function Get-ComputerModel{
		param (
			[Parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
		Write-Host -NoNewline "$Computer`tModel: "
		(Get-CimInstance -ComputerName $Computer -ClassName Win32_ComputerSystem).Model
	}
	
	
	
	function Get-CPUModel {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
		Write-Host -NoNewline "$Computer`tCPU: "
		(Get-CimInstance -ComputerName $Computer -ClassName Win32_Processor).Name
	}
	
	
	
	function Get-GPUModel {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
		
		$GPUs = Get-CimInstance -ComputerName $Computer -ClassName Win32_VideoController | Where-Object {$_.Name -notmatch 'DameWare'}
		foreach ($GPU in $GPUs) {
			Write-Host "$Computer - GPU:`t $($GPU.Name)"
		}
	}
	
	
	
	function Get-MemoryCapacity {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
			$MEMORY = (Get-CimInstance -ComputerName $Computer -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
		Write-Host "$Computer`tMemory: $MEMORY GB"
	}
	
	
	
	function Get-DiskInformation {
		param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
		
		if (-Not (Get-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
		$disks = Get-CimInstance -ComputerName $Computer -ClassName Win32_DiskDrive
		foreach ($disk in $disks) {
			$SizeInGB = [math]::round($disk.Size / 1GB, 2)
			$MediaType = $disk.MediaType
			Write-Host "$Computer Disk ($($disk.DeviceID)):`t Size = $SizeInGB GB, Type = $MediaType"
		}
	}
	
	
	
	function Get-WindowsBuild{
		param (
			[Parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
		Write-Host -NoNewline "$Computer`tBuild: "
		(Get-CimInstance  -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
	} 
	
	
	
	function Get-WindowsVersion{
		param (
			[Parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
	
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
			Write-Host "$Computer`tN/A"
			return
		}
	
		$BuildNumberToWindowsVersion = @{
			"9200" = "Windows 8 and Windows Server 2012 [Build  9200]"
			"9600" = "Windows 8.1 and Windows Server 2012 R2 [Build 9600]"
			"10240" = "Windows 10 - 1507 (RTM)`t[Build 10240]"
			"10586" = "Windows 10 - 1511`t[Build 10586] - End of servicing"
			"14393" = "Windows 10 - 1607 and Windows Server 2016 [Build 14393] - End of servicing"
			"15063" = "Windows 10 - 1703`t[Build 15063] - End of servicing"
			"16299" = "Windows 10 - 1709`t[Build 16299] - End of servicing"	
			"17134" = "Windows 10 - 1803`t[Build 17134] - End of servicing"
			"17763" = "Windows 10 - 1809 and Windows Server 2019 [Build 17763]"
			"18362" = "Windows 10 - 1903`t[Build 18362] - End of servicing"
			"18363" = "Windows 10 - 1909`t[Build 18363] - End of servicing"
			"19041" = "Windows 10 - 2004`t[Build 19041] - End of servicing"
			"19042" = "Windows 10 - 20H2`t[Build 19042] - End of servicing"
			"19043" = "Windows 10 - 21H1`t[Build 19043] - End of servicing"
			"19044" = "Windows 10 - 21H2`t[Build 19044] - End of servicing"
			"19045" = "Windows 10 - 22H2`t[Build 19045]"
			"22000" = "Windows 11 - 21H2`t[Build 22000]"
			"20348" = "Windows Server 2022`t[Build 20348]"
			"22621" = "Windows 11 - 22H2`t[Build 22621]"
			"22631" = "Windows 11 - 23H2`t[Build 22631]"
		}
	
		$buildNumber = (Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
		$winVersion = $BuildNumberToWindowsVersion[$buildNumber]
		Write-Host "$Computer`t$winVersion"
	} 
	
	
	
	<# 
	
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
	
	#>
	
	function Convert-ToMacAddress {
		param (
			[string]$macAddress
		)
		if ($macAddress -match "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$") {
			$macAddress = $macAddress -replace '[:-]', ''
			$macAddress = $macAddress.ToUpper()
			$macAddress = $macAddress -replace '(.{2})', '$1:'
			$macAddress = $macAddress.TrimEnd(':')
			echo -n $macAddress | Set-Clipboard
			return $macAddress
		} 
		
		if ($macAddress -match "^([0-9A-Fa-f]{12})$") {
			$macAddress = $macAddress.ToUpper()        
			$macAddress = $macAddress -replace '(.{2})', '$1:'
			$macAddress = $macAddress.TrimEnd(':')
			echo -n $macAddress | Set-Clipboard
			return $macAddress
		}
	
		Write-Host "Invalid MAC address."
		return $null
	}
	
	function Get-IPMILicense {
		param (
			[string]$macAddress
		)
	
		if ($macAddress -ne '') { 
			$VALIDMAC = Convert-ToMacAddress $macAddress
			if ($VALIDMAC -eq $null) { break } 
		}
	
		if ($macAddress -eq '') {
			Write-Output ""
			Write-Host "Enter MAC-Address of SuperMicro IPMI Interface."
			$MBMACADDR = (Read-Host "MAC-Address").Replace(' ', '').Replace(':', '').Replace('-', '')
			$VALIDMAC = Convert-ToMacAddress $MBMACADDR
			Write-Output ""
			if ($VALIDMAC -eq $null) { break } 
		}
	
		$MACBYTES = [System.Linq.Enumerable]::Range(0, $MBMACADDR.Length / 2) | ForEach-Object { [Convert]::ToByte($MBMACADDR.Substring($_ * 2, 2), 16) }
		$MACSHA1 = New-Object System.Security.Cryptography.HMACSHA1
		$MACSHA1.Key = [Convert]::FromHexString('8544E3B47ECA58F9583043F8')
		$HASHBYTES = $MACSHA1.ComputeHash($MACBYTES)
		$HASHHEX = ([BitConverter]::ToString($HASHBYTES) -replace '-').Substring(0, 24)
		$LICENSEKEY = ($HASHHEX -split "(.{4})", 6 | Where-Object { $_ }) -join '-'
		Write-Output "`tMAC-Address:"
		Write-Output "`t$VALIDMAC"
		Write-Output ""
		Write-Output "`tLicense Key:"
		Write-Output "`t$LICENSEKEY "
		Write-Output ""
	}
	
	
	
	function Get-MACAddress {
		param(
			[Parameter(Mandatory=$true, Position=0)]
			[string]$IPAddressOrHostname
		)
	
		try {
			$isIP = [bool](([System.Net.IPAddress]::TryParse($IPAddressOrHostname, [ref]$null)))
			if ($isIP) {
				$IPAddress = $IPAddressOrHostname
			} else {
				$IPAddress = [System.Net.Dns]::GetHostAddresses($IPAddressOrHostname) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1 -ExpandProperty IPAddressToString
			}
	
			if (-not $IPAddress) {
				Write-Host "Failed to resolve IP address or hostname: $IPAddressOrHostname" -ForegroundColor Red
				return $null
			}
	
			if (-Not (Test-OnlineStatus -Computer $IPAddress)) {
				return $null
			}  
	
			$arpOutput = arp -a | Where-Object { $_ -like "*$IPAddress*" }
			if ($arpOutput) {
				$macAddress = ($arpOutput -replace '\s+', ' ' -split ' ' | Select-Object -Index 2).ToUpper() -replace '-', ':'
				if ($macAddress -match '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
					return $macAddress
				} else {
					return $null
				}
			} else {
				return $null
			}
		} catch {
			return $null
		}
	}
	
	
	
	function Get-Gaps { 
		[CmdletBinding()]
		param (
			[switch]$NB,
			[switch]$WS,
			[switch]$Notebook,
			[switch]$Notebooks,
			[switch]$Workstation,
			[switch]$Workstations
		)
	
		$hostnameRanges = @(
			"KTS-MG-NB", "001", "004",
			"KTS-MG-WS", "001", "006",
			"TKM-MG-NB", "001", "035",
			"TKM-MG-WS", "001", "085",
			"TKS-MG-NB", "001", "022",
			"TKS-MG-WS", "001", "004"
		)
	    
		$missingComputers = @()
	
		for ($i = 0; $i -lt $hostnameRanges.Length; $i += 3) {
			$prefix = $hostnameRanges[$i]
			$start = [int]$hostnameRanges[$i + 1]
			$end = [int]$hostnameRanges[$i + 2]
	
			for ($j = $start; $j -le $end; $j++) {
				$computerName = "{0}{1:D3}" -f $prefix, $j
	
				    $matchNB = $NB -or $Notebook -or $Notebooks
				    $matchWS = $WS -or $Workstation -or $Workstations
				$matchANY = $matchNB -or $matchWS
	
				if (($matchNB -and $prefix -like "*-NB*") -or ($matchWS -and $prefix -like "*-WS*")) {
					if (-not (Get-ADComputer -Filter {Name -eq $computerName})) {
						$missingComputers += $computerName
					}
				} else {
					if (-not $matchANY) { 
						if (-not (Get-ADComputer -Filter {Name -eq $computerName})) {
							$missingComputers += $computerName
						    }
					    }
				}
			}
		}
		if ($missingComputers) {
			Write-Host "Unused Hostnames: "
			$missingComputers
		    }
	}
	
	
	function Get-ComputerList {
		$COMPUTERS = Get-ADComputer -Filter *
		$COMPUTERINFO = @()
		
		foreach ($COMPUTER in $COMPUTERS) {
			$LASTLOGONDATE = Get-ADComputer $COMPUTER -Properties lastLogonDate, Description, DistinguishedName | 
			Select-Object Name, Description, LastLogonDate, 
				@{Name="Location"; Expression={
					$ouComponents = ($_ | Select-Object -ExpandProperty DistinguishedName) -replace '^(CN|OU)=[^,]+,|,DC[^,]+', '' -split '(?<=OU=.+?)(?=OU=)' | ForEach-Object { $_ -replace 'OU=', '' } | ForEach-Object { $_.Trim(',') }    
					[array]::Reverse($ouComponents)
					$ouString = "tkm.local/" + ($ouComponents -join '/')
					$ouString
					    }
				}
			$COMPUTERINFO += $LASTLOGONDATE
		}
		$COMPUTERINFO | Where-Object { $_.Location -ne $null } | Out-GridView
	}
	    
	
	function Get-LockedADAccounts {
		$lockedOutAccounts = Search-AdAccount -LockedOut
		$selectedProperties = "lastlogondate", "name", "samaccountname"
		if ($lockedOutAccounts.Count -eq 0) {
			Write-Output "No accounts locked out"
		} else {
			$lockedOutAccounts | Select-Object $selectedProperties
		}
	}
	
	
	
	function Test-Credentials {
		[CmdletBinding()]
		Param (
			[Parameter(Mandatory=$true)]
			[string]$UserName
		)
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
		$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		if ($UserAccount -ne $null) {
			if ($null -ne $UserAccount.AccountLockoutTime) {
			Write-Warning "Account of $UserName is locked."
			return $null
			}
		}
	
		$SecurePassword = Read-Host "Enter password for $UserName" -AsSecureString
		if (-not $SecurePassword) {
			Write-Warning 'Test-ADCredential: Password cannot be empty'
			return
		}
	
		$VALIDCRED = $DS.ValidateCredentials($UserName, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)))
	
		if ($VALIDCRED) {
			Write-Output "Credentials for $UserName were correct."
		} else {
			Write-Warning "Credentials for $UserName were incorrect."
			$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
			if ($user) {
				if ($null -ne $User.AccountLockoutTime) {
					Write-Warning "Account of $UserName is locked out."
					$User.UnlockAccount()
					Write-Host "Account of $UserName unlocked."
				}
			}
		}
	}
	
	
	
	<#
	.Synopsis
	Verify Active Directory credentials
	.DESCRIPTION
	This function verifies AD User Credentials. The function returns result as boolean.
	.NOTES   
	Name: Test-ADCredentials
	Version: 1.5
	.PARAMETER UserName
	Samaccountname of AD user account
	.PARAMETER Password
	Password of AD User account
	.EXAMPLE
	Test-ADCredentials -username username1 -password Password1!
	Test-ADCredentials Toni PWTest#12345
	Description:
	Verifies if the username and password provided are correct, returning either true or false based on the result
	#>
	
	function Test-ADCredentials {
		[CmdletBinding()]
		Param (
			[string]$UserName,
			[string]$Password
		)
		if (!($UserName) -or !($Password)) {
			Write-Warning 'Test-ADCredential: Please specify both user name and password'
		} else {
			Add-Type -AssemblyName System.DirectoryServices.AccountManagement
			$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
			$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	
			$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
			if ($UserAccount -ne $null) {
				if ($null -ne $UserAccount.AccountLockoutTime) {
				Write-Warning "Account of $UserName is locked."
				return $null
				}
			}
		
	
	
		#	if ($user) {
		#		if ($User.AccountLockoutTime -ne $null) {
		#		if ($null -ne $User.AccountLockoutTime) {
		#			$User.UnlockAccount()
		#			Write-Host "Account of $UserName unlocked."
		#			Write-Host "Account of $User unlocked."
		#		}
		#	}
			$VALIDCRED = $DS.ValidateCredentials($UserName, $Password)
			if ($VALIDCRED) {
				Write-Output "Credentials for $UserName were correct."
			} else {
				Write-Warning "Credentials for $UserName were incorrect."
				$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	
				if ($UserAccount -ne $null) {
					if ($null -ne $UserAccount.AccountLockoutTime) {
						Write-Warning "Account of $UserName is locked."
						$UserAccount.UnlockAccount()
						Write-Host "Account of $UserAccount unlocked."
					}
				}
	
			}
		}
	}
	
	
	
	function Test-DefaultCredentials {
		[CmdletBinding()]
		Param (
			[string]$UserName
		)
		if (!$UserName) {
			$UserName = Read-Host "Enter the username"
		}
		$PASSWORDS = @("TKM#12345", "TKS#12345", "KTS#12345", "THS#12345")
		$passwordFound = $false
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
	
		$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		if ($UserAccount -ne $null) {
			if ($null -ne $UserAccount.AccountLockoutTime) {
			Write-Warning "Account of $UserName is locked."
			return $null
			}
		}
	
	
		foreach ($PASSWORD in $PASSWORDS) {
			$isValid = $DS.ValidateCredentials($UserName, $PASSWORD)
				if ($isValid) {
					$PasswordPrefix = $PASSWORD.Substring(0, 3)
					Write-Warning "${PasswordPrefix}-default password is in use."
					$passwordFound = $true
					break
				} else {
					Write-Warning "Credentials for $UserName were incorrect."
					$UserAccount = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		
					if ($UserAccount -ne $null) {
						if ($null -ne $UserAccount.AccountLockoutTime) {
							Write-Warning "Account of $UserName is locked."
							$UserAccount.UnlockAccount()
							Write-Host "Account of $UserAccount unlocked."
						}
					}
				}
		}		
		#	$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		#	if ($User.AccountLockoutTime -ne $null) {
		#	if ($null -ne $User.AccountLockoutTime) {
		#			$User.UnlockAccount()
		#			Write-Host "Account of $UserName unlocked."
		#			Write-Host "Account of $User unlocked."
		#	}
		
		if (-not $passwordFound) {
			Write-Host "$UserName is not using any of the default passwords."
		}
	}
	
	
	
	function Unlock-ADAccount {
		param (
			[Parameter(Mandatory = $true)]
			[string]$UserName
		)
	
		$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
		try {
			if ($null -ne $User.AccountLockoutTime) {
				$User.UnlockAccount()
				Write-Host "Account of $UserName unlocked."
				Write-Host "Account of $User unlocked."
			}
		}
		catch {
			Write-Host "Failed to unlock account '$UserName'."
			Write-Host "Error: $_"
		}
	}
	
	
	function Start-WSUSCheckin {
		param (
			[Parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
			[string]$Computer
		)
		if (-Not (Test-WinRMStatus -Computer $Computer)) {
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
	
	
	
	function Merge-Module {
		param (
			[string] $ModuleName,
			[string] $ModulePathSource,
			[string] $ModulePathTarget
		)
		$ScriptFunctions = @( Get-ChildItem -Path $ModulePathSource\*.ps1 -ErrorAction SilentlyContinue -Recurse )
		$ModulePSM = @( Get-ChildItem -Path $ModulePathSource\*.psm1 -ErrorAction SilentlyContinue -Recurse )
		foreach ($FilePath in $ScriptFunctions) {
			$Results = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
			$Functions = $Results.EndBlock.Extent.Text
			$Functions | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
		}
		foreach ($FilePath in $ModulePSM) {
			$Content = Get-Content $FilePath
			$Content | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
		}
		Copy-Item -Path "$ModulePathSource\$ModuleName.psd1" "$ModulePathTarget\$ModuleName.psd1"
	}
	
	
	
	
	
