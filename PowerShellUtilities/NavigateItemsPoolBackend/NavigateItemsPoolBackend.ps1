
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

<# Import Data #>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.ps1', 'Data.ps1'
$path = Join-Path $here $sut
. $path
#>

Function Get-ItemCategoriesAndSources 
{
	[CmdletBinding()]
	param()

	return $ItemCategoriesAndSources 

} # Get-ItemCategoriesAndSources

if(-not $LoadScript.IsPresent)
{
	$Data = Get-ItemCategoriesAndSources 
	if($Data) 
	{
		Write-Output "Script data imported"
	}
	else 
	{
		Write-Output "Script data not imported"
	}
	
	Use-CommandFromFrontend | Out-Null
	Confirm-CommandExecutionToFrontend | Out-Null
	$ServerPipeName | Get-CommandFromFrontend -UriDataJson $Data.UriDataJson
}