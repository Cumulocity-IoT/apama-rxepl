#!/usr/bin/pwsh -f

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

param (
	[string]$travisJobId,
	[string]$coverageFile = "$((Get-Childitem -Path ./test -Include merged.eplcoverage -File -Recurse)[0].FullName)"
)

$coverageInfo = Get-Content -Path $coverageFile | ConvertFrom-Csv -Header Stage,Line,Block,File | Where {$_.File -like '*/output/*'} | % { $_.Line = [int]$_.Line; $_.Block = [int]$_.Block; $_ } | Sort-Object -Property File,Line,Block,Stage 

$coveredBlocks = @()
$uncoveredBlocks = @()

For ($i=0; $i -lt $coverageInfo.length; $i++) {
	$coverageLine = $coverageInfo[$i]
	If ($coverageLine.Stage -eq "CODE") {
		If ((($i + 1) -ge $coverageInfo.length) -or ($coverageInfo[$i + 1].Stage -eq "CODE")) {
			$uncoveredBlocks += $coverageLine
		} else {
			$coveredBlocks += $coverageLine
		}
	}
}

$blockHits = $coveredBlocks | Group-Object Line,File,Block | %{
    New-Object psobject -Property @{
        Line = $_.Group[0].Line
		File = $_.Group[0].File
		Block = $_.Group[0].Block
		# There's no block hit count in eplcoverage so we'll assume it was hit once
        Count = 1
    }
}
$blockHits += $uncoveredBlocks | Group-Object Line,File,Block | %{
    New-Object psobject -Property @{
        Line = $_.Group[0].Line
		File = $_.Group[0].File
		Block = $_.Group[0].Block
        Count = 0
    }
}
$blockHits = $blockHits | Sort-Object -Property File,Line,Block

$jsonCoverage = New-Object psobject -Property @{
	service_job_id = $travisJobId
	service_name = "travis-ci"
	source_files = $blockHits | Group-Object File | %{
		$fileName = $_.Name
		New-Object psobject -Property @{
			name = Resolve-Path -Relative $_.Name | %{$_ -replace "\\","/"} | %{$_ -replace ".*/output/.*/code","src"}
			source_digest = (Get-FileHash $_.Name -Algorithm MD5).Hash
			coverage = $(
				$lineHits = $blockHits | Where {$_.File -eq $fileName} | Group-Object Line | %{	
					New-Object psobject -Property @{
						Line = $_.Group[0].Line
						Count = ($_.Group | Measure-Object -Maximum Count).Maximum
					}
				}
				$coverageArray = @()
				Foreach ($coverageLine in $lineHits) {
					While($coverageArray.length -lt ($coverageLine.Line - 1)) {
						$coverageArray += $null
					}
					$coverageArray += $coverageLine.Count
				}
				$coverageArray
			)
			# There's no branch information in eplcoverage - we can aproximate this with block coverage:
			# If one block has been hit but another hasn't (on the same line) then we've missed at least one branch
			branches = $_.Group | Group-Object Line | Where {(($_.Group | %{$_.Count -gt 0}) -contains $true) -and (($_.Group | %{$_.Count -eq 0}) -contains $true)} | %{ 
				@(
					$_.Group[0].Line, 0, 0, 1, 
					$_.Group[0].Line, 0, 1, 0
				)
			}
		}
	}
} | ConvertTo-Json -Depth 10 -Compress

Invoke-WebRequest -Uri https://coveralls.io/api/v1/jobs -Method POST -Body @{json=$jsonCoverage}