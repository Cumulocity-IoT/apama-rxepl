#!/usr/bin/pwsh -f

# Copyright 2018 Software AG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

param (
   [string]$sagInstallDir = (./misc/getSagInstallDir.ps1),
   [string]$output = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/output/RxEPL",
   [switch]$forTest
)

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$apamaInstallDir = "$sagInstallDir/Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation"
}

echo "Using Apama located in: $apamaInstallDir"

$apamaBin = "$apamaInstallDir/bin"

./clean.ps1 -sagInstallDir $sagInstallDir

$version = "$(cat ./version.txt)-$(git rev-parse --short HEAD)"

New-Item -ItemType Directory -Force "$output" | out-null
New-Item -ItemType Directory -Force "$output/cdp" | out-null
& "$apamaBin/engine_deploy" --outputCDP "$output/cdp/RxEPL.cdp" src
& "$apamaBin/engine_deploy" --outputDeployDir "$output/code" src
if (-not $forTest) {
	Remove-Item "$output/code/initialization.yaml"
}

cp -r "$PSScriptRoot/docs" "$output/docs"

# Create the bundle
$files = & "$apamaBin/engine_deploy" --outputList stdout src | %{$_ -replace ".*[\\/]src[\\/]rx[\\/]","code/rx/"} | %{$_ -replace "\\","/"}
$bundleFileList = $files | %{$_ -replace "(.+)","`t`t`t<include name=`"`$1`"/>"} | Out-String
$bundleResult = cat "$PSScriptRoot/bundles/BundleTemplate.bnd"
$bundleResult = $bundleResult | %{$_ -replace "<%date%>", (Get-Date -UFormat "%Y-%m-%d")}
$bundleResult = $bundleResult | %{$_ -replace "<%version%>", $version}

$cdpBundle = $bundleResult | %{$_ -replace "<%fileList%>","`t`t`t<include name=`"cdp/RxEPL.cdp`"/>"} | %{$_ -replace "<%displayName%>", "RxEPL CDP"}
$sourceBundle = $bundleResult | %{$_ -replace "<%fileList%>",$bundleFileList} | %{$_ -replace "<%displayName%>", "RxEPL"}

New-Item -ItemType Directory -Force "$output/bundles" | out-null
# Write out utf8 (no BOM)
[IO.File]::WriteAllLines("$output/bundles/RxEPL.bnd", $sourceBundle)
[IO.File]::WriteAllLines("$output/bundles/RxEPL-CDP.bnd", $cdpBundle)

cp -r "$PSScriptRoot/misc" "$output/misc"
mv "$output/misc/deploy.bat" "$output/deploy.bat"

cp -r "$PSScriptRoot/samples" "$output/samples"

# Write out utf8 (no BOM)
[IO.File]::WriteAllLines("$output/version.txt", $version)

cp -r "$PSScriptRoot/LICENSE" "$output/LICENSE"

if (-not $forTest) {
	# Zip
	if (Get-Command Compress-Archive -errorAction SilentlyContinue) {
		Compress-Archive -Path $output -CompressionLevel Optimal -DestinationPath "$output-$version.zip"
	} else {
		& "C:/Program Files/7-Zip/7z.exe" a "$output-$version.zip" $output
	}
}