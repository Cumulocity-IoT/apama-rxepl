param (
   [string]$sagInstallDir = (.\misc\getSagInstallDir),
   [string]$output = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\output\RxEPL"
)

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$apamaInstallDir = "$sagInstallDir\Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation"
}

echo "Using Apama located in: $apamaInstallDir"

$apamaBin = "$apamaInstallDir\bin"

if (-not (Test-Path "$output\cdp\RxEPL.cdp")) {
	echo "Unable to find build, building..."
	.\build
}

cmd.exe /c "$apamaBin\apama_env.bat && cd test && pysys run -n8 -vCRIT"