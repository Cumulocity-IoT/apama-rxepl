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
	[string]$travisJobId,
	[string]$coverageFile = "$((Get-Childitem -Path ./test -Include merged.eplcoverage -File -Recurse)[0].FullName)"
)

$coverageInfo = Get-Content -Path $coverageFile | ConvertFrom-Csv -Header Stage,Line,Block,File | Where {$_.File -like '*/output/*'} | % { $_.Line = [int]$_.Line; $_ } | Sort-Object -Property File,Line,Block,Stage 

$coveredBlocks = @()
$uncoveredBlocks = @()

For ($i=0; $i -lt $coverageInfo.length; $i++) {
	$coverageLine = $coverageInfo[$i]
	If ($coverageLine.Stage -eq "CODE") {
		If (($i + 1 -eq $coverage.length) -or ($coverageInfo[$i + 1].Stage -eq "CODE")) {
			$uncoveredBlocks += $coverageLine
		} else {
			$coveredBlocks += $coverageLine
		}
	}
}

$lineHitCount = $coveredBlocks | Group-Object Line,File | %{
    New-Object psobject -Property @{
        Line = $_.Group[0].Line
		File = $_.Group[0].File
        Count = $_.Count
    }
}

$lineHitCount += $uncoveredBlocks | Group-Object Line,File | %{
    New-Object psobject -Property @{
        Line = $_.Group[0].Line
		File = $_.Group[0].File
        Count = 0
    }
}

$lineHitCount = $lineHitCount | Group-Object File,Line | %{
    New-Object psobject -Property @{
        Line = $_.Group[0].Line
		File = $_.Group[0].File
        Count = ($_.Group | Measure-Object Count -Sum).Sum
    }
} | Sort-Object -Property File,Line

$jsonCoverage = New-Object psobject -Property @{
	service_job_id = $travisJobId
	service_name = "travis-ci"
	source_files = $lineHitCount | Group-Object -Property File | %{
		New-Object psobject -Property @{
			name = Resolve-Path -Relative $_.Name | %{$_ -replace "\\","/"} | %{$_ -replace ".*/output/Lambdas/code","src"}
			source_digest = (Get-FileHash $_.Name -Algorithm MD5).Hash
			coverage = $(
				$coverageArray = @()
				Foreach ($coverageLine in $_.Group) {
					While($coverageArray.length -lt ($coverageLine.Line - 1)) {
						$coverageArray += $null
					}
					$coverageArray += $coverageLine.Count
				}
				$coverageArray
			)
		}
	}
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri https://coveralls.io/api/v1/jobs -Method POST -Body @{json=$jsonCoverage}