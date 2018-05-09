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
   [string]$output = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/output/RxEPL"
)

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$apamaInstallDir = "$sagInstallDir/Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation"
}

echo "Using Apama located in: $apamaInstallDir"

$apamaBin = "$apamaInstallDir/bin"

if (-not (Test-Path "$output/code/initialization.yaml")) {
	echo "Unable to find build, building..."
	./build.ps1 -forTest -sagInstallDir $sagInstallDir -output $output
}

if ($IsLinux) {
	/bin/bash -c ". $apamaBin/apama_env; cd test; pysys run -n8 -vCRIT"
} else {
	cmd.exe /c "$apamaBin\apama_env.bat && cd test && pysys run -n8 -vCRIT"
}

Read-Host "Finished! Press Return to Exit..."