<#
	Given a namespace or type, enumerate all dll assemblies and modules that implement 
	the namespace module or type
#> 

Function List-DllModules 
{
	[CmdletBinding()]
	Param 
	(
		[parameter(ValueFromPipeline=$true, Mandatory=$true)] 
		[ValidateNotNullOrEmpty()] 
		[System.String]
		$NamespaceOrType
	)

	<#
	1. System Drive 
	2. Scan for any DLL's using Get-ChildItem -File -Recurse | ? Name -Match "\.dll\Z" 
	3. On each DLL, do ...
	#>
}