function Get-WindowsBuild{
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tN/A"
		return
	}

	Write-Host -NoNewline "$Computer`tBuild: "
	(Get-WmiObject -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
} 
