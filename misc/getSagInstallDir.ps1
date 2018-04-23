$regEntry = Get-ItemProperty -Path "HKLM:SOFTWARE\WOW6432Node\Software AG\Installer\Preferences" -Name "Path1" -ErrorAction SilentlyContinue

if (-not $regEntry) {
	if (Test-Path "C:\SoftwareAG") {
		return "C:\SoftwareAG"
	} else {
		return Read-Host "Can't find SoftwareAG install folder, where is it located?"
	}
} else {
	return $regEntry.Path1
}