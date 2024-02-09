function Get-WindowsBuild{
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-WinRMStatus -Computer $Computer)) {
		Write-Host "$Computer`tN/A"
		return
	}

	Write-Host -NoNewline "$Computer`tBuild: "
	(Get-CimInstance  -ComputerName $Computer -ClassName Win32_OperatingSystem).BuildNumber
} 
