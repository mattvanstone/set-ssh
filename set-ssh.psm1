<#
.SYNOPSIS
Starts or Stops SSH on a host
.DESCRIPTION
Takes a host and state as input and starts or stops the SSH service
.PARAMETER VMHost
The name of a host to start ssh on
.PARAMETER State
State to set the SSH service to. Valid values are Start or Stop
.EXAMPLE
Start-SSH esx01.domain.com Start
.EXAMPLE
Start-SSH esx01.domain.com Stop
.EXAMPLE
14..15 | % { Set-SSH -VMHost esx$_.domain.com Stop }
#>
Function Set-SSH {
	[CmdletBinding()] Param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]$VMHost,
		[Parameter(Mandatory=$True)][ValidateSet("Start","Stop")][String]$State
	)

	Process {
		$service = Get-VMHost $VMHost | Get-VMHostService | Where {$_.key -like "TSM-SSH"}
		$service | % {
			if ($State -eq "Start") {
				if (-not $_.running) {
					$_ | Start-VMHostService -Confirm:$false | Out-Null
					Write-Host "$($_.Label) on $VMHost started"
					$service = Get-VMHost $VMHost | Get-VMHostService | Where {$_.key -like "TSM-SSH"}
				}
				else {Write-Warning "$($_.Label) on $VMHost already started"}
			}
			if ($State -eq "Stop") {
				if ($_.running) {
					$_ | Stop-VMHostService -Confirm:$false | Out-Null
					Write-Host "$($_.Label) on $VMHost stopped"
					$service = Get-VMHost $VMHost | Get-VMHostService | Where {$_.key -like "TSM-SSH"}
				}
				else {Write-Warning "$($_.Label) on $VMHost already stopped"}
			}
		}
	}
	
	End {
	}
}