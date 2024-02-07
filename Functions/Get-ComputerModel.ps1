function Get-ComputerModel{
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Computer
	)

	if (-Not (Get-OnlineStatus -Computer $Computer)) {
                Write-Host "$Computer`tN/A"
		return
	}

	Write-Host -NoNewline "$Computer`tModel: "
	(Get-WmiObject -ComputerName $Computer -ClassName Win32_ComputerSystem).Model
}