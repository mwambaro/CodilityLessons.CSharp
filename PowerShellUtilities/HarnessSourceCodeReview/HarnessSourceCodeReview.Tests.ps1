$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\..+', ''

#Write-OutPut "Sut: $sut"

$sourceItem = Get-ChildItem -Path $here | Where-Object {$_ -Match "\A$sut\.(psm\d|ps\d)"}
$module = {}
$script = {}

if($sourceItem.Name -Match "\A$sut\.psm\d\Z")
{
	$module = "$here\$($sourceItem.Name)"
}
elseif($sourceItem.Name -Match "\A$sut\.ps\d\Z")
{
	$script = "$here\$($sourceItem.Name)"
	$module = {}
}

Write-Output "Module: $module"
Write-Output "Script: $script"

Import-Module $module -ErrorAction SilentlyContinue
. $script -ErrorAction SilentlyContinue


Describe "Find-KeywordInSources" {
	
	It "should find matches in files" {
		$matches = Find-KeywordInSources -KeywordOrPattern "ValueFromPipelineBy" -SourcesFolderPath @($(Get-Location))
		$matches.GetType().ToString() | Should Be "System.Collections.HashTable"
	}
}
