param (
   [string]$sagInstallDir = (.\misc\getSagInstallDir),
   [string]$output = "$PSScriptRoot\output\RxEPL"
)

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