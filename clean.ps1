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

if (Test-Path $output) {
	rm -r -Force $output
}

cmd.exe /c "$apamaBin\apama_env.bat && cd test && pysys clean"