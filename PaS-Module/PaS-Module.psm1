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
function Get-User {
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
	$SecurePassword = Read-Host "Enter password for $UserName" -AsSecureString
	if (-not $SecurePassword) {
		Write-Warning 'Test-ADCredential: Password cannot be empty'
		return
	}
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
	$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	if ($user) {
	#	if ($User.AccountLockoutTime -ne $null) {
		if ($null -ne $User.AccountLockoutTime) {
			$User.UnlockAccount()
			Write-Host "Account unlocked"
		}
	}
	$VALIDCRED = $DS.ValidateCredentials($UserName, [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)))

	if ($VALIDCRED) {
		Write-Output "Credentials for $UserName were correct."
	} else {
		Write-Warning "Credentials for $UserName were incorrect."
	}
}
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
		if ($user) {
	#		if ($User.AccountLockoutTime -ne $null) {
			if ($null -ne $User.AccountLockoutTime) {
				$User.UnlockAccount()
							Write-Host "Account unlocked"
			}
		}
		$VALIDCRED = $DS.ValidateCredentials($UserName, $Password)
		if ($VALIDCRED) {
			Write-Output "Credentials for $UserName were correct."
		} else {
			Write-Warning "Credentials for $UserName were incorrect."
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
	foreach ($PASSWORD in $PASSWORDS) {
		$isValid = $DS.ValidateCredentials($UserName, $PASSWORD)
			if ($isValid) {
			$PasswordPrefix = $PASSWORD.Substring(0, 3)
			Write-Warning "Password starting with $PasswordPrefix is in use."
			$passwordFound = $true
			break
		}
		$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($DS, $UserName)
	#	if ($User.AccountLockoutTime -ne $null) {
		if ($null -ne $User.AccountLockoutTime) {
				$User.UnlockAccount()
#			Write-Host "Account unlocked"
		}
	}
	if (-not $passwordFound) {
		Write-Host "User is not using any of the default passwords."
	}
}
function Unlock-ADAccount {
	param (
		[Parameter(Mandatory = $true)]
		[string]$SamAccountName
	)

	try {
		Unlock-ADAccount -Identity $SamAccountName -ErrorAction Stop
		Write-Host "Account '$SamAccountName' has been unlocked."
	}
	catch {
		Write-Host "Failed to unlock account '$SamAccountName'."
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
