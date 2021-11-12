
param
(
	[parameter(Mandatory=$true, ValueFromPipeline=$true)]
	[ValidateNotNullOrEmpty()]
	[System.String]$ServerPipeName,
	[switch]$LoadScript
)

<# Import Module #>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.ps1', '.psm1'
$path = Join-Path $here $sut
Import-Module -Name $path
#>

if(-not $LoadScript.IsPresent)
{
	Use-CommandFromFrontend | Out-Null
	Confirm-CommandExecutionToFrontend | Out-Null
	$ServerPipeName | Get-CommandFromFrontend
}