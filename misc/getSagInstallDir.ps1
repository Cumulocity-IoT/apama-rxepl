# Copyright (c) 2018 Software AG, Darmstadt, Germany and/or its licensors
#
# SPDX-License-Identifier: Apache-2.0
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

$regEntry = Get-ItemProperty -Path "HKLM:SOFTWARE\WOW6432Node\Software AG\Installer\Preferences" -Name "Path1" -ErrorAction SilentlyContinue

if (-not $regEntry -or -not (Test-Path $regEntry.Path1)) {
	if (Test-Path "C:\SoftwareAG") {
		return "C:\SoftwareAG"
	} else {
		return Read-Host "Can't find SoftwareAG install folder, where is it located?"
	}
} else {
	return $regEntry.Path1
}