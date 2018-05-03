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
   [string]$sagInstallDir,
   [switch]$notInteractive
)

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

if (!$sagInstallDir) {
	$sagInstallDir = (& "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\getSagInstallDir")
	
	if (!$notInteractive) {
		$temp = Read-Host "Where is your SoftwareAG install folder? (blank=$sagInstallDir)"
	}

	if (-not $temp) {} else {
		$sagInstallDir = $temp;
	}
}

$apamaInstallDir = "$sagInstallDir\Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation: $sagInstallDir\Apama"
}

$rxEplHome = (Resolve-Path "$PSScriptRoot\..") -replace "\\","/"

$steFile = cat "$PSScriptRoot\template.ste"
$steFile = $steFile | %{$_ -replace "<%RX_EPL_HOME%>",$rxEplHome}
$steFile | Out-File -encoding utf8 "$sagInstallDir/Designer/extensions/rxepl.ste"

[IO.File]::WriteAllLines("$rxEplHome\rxepl.properties", "RX_EPL_HOME=$rxEplHome")

if ($notInteractive) {
	Write-Host "Done! Please restart designer."
} else {
	Read-Host -Prompt "Done! Please restart designer. Press Return to exit..."
}