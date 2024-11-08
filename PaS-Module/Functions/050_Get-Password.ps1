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
    
	$CURRENT_DATETIME = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	$DAY_OF_WEEK = Get-Date -UFormat "%u"
	$GERMAN_DAYS = @("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")
	$DAY_OF_WEEK_GERMAN = $GERMAN_DAYS[$DAY_OF_WEEK - 1]
    
	$LOG_ENTRY = "$CURRENT_DATETIME`t$DAY_OF_WEEK_GERMAN`t$GENERATED_PASSWORD"
	Add-Content -Path "C:/logs/pw.log" -Value $LOG_ENTRY
    }
    