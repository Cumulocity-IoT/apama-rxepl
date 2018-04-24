param (
   [string]$sagInstallDir = (& "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\getSagInstallDir"),
   [string]$output = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\output\RxEPL"
)

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$temp = Read-Host "Where is your SoftwareAG install folder? (blank=$sagInstallDir)"

if (-not $temp) {} else {
	$sagInstallDir = $temp;
}

$apamaInstallDir = "$sagInstallDir\Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation"
}

$steFile = cat "$PSScriptRoot\template.ste"
$steFile = $steFile | %{$_ -replace "<%RX_EPL_HOME%>",(Resolve-Path "$PSScriptRoot\..")}

$steFile | Out-File -encoding utf8 "$sagInstallDir/Designer/extensions/rxepl.ste"

Read-Host -Prompt "Done! Please restart designer. Press Return to exit..."