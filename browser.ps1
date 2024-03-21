Get-Content C:\temp\assoc.xml | Select-String -Pattern "Firefox|.xml|DefaultAssociations" | Out-File -Encoding utf8 C:\temp\browser.xml



#  Get-Content .\assoc.xml |
#  Select-String -Pattern "Chrome|.xml|DefaultAssociations"|
#  Out-File -Encoding utf8 .\browser.xml
