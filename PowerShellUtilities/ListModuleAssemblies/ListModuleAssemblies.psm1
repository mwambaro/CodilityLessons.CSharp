<#
	Given a namespace or type, enumerate all .NET dll assemblies and modules that implement 
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
	OR 
	any other convenient way.
	#>

	$assemblies = @()

	# From loaded assemblies
	$assemblies = [AppDomain]::CurrentDomain.GetAssemblies() | % { 
		$assembly = $_
		if($assembly.PSObject.Methods.Name -Contains "GetExportedTypes")
		{
			$assembly.GetExportedTypes() | % {
				$type = $_ 
				if(
					($type.PSObject.Properties.Name -Contains "BaseType") -and 
					($type.PSObject.Properties.Name -Contains "Name")
				){
					if("$($type.BaseType).$($type.Name)" -Match $NamespaceOrType) 
					{
						$assemblies += $assembly
					}
				}
			} 
		}
	} 

	# From scanning: 
	# You must check whether a DLL is a .NET Intermediary Language assembly, first

	return $assemblies

} # List-DllModules