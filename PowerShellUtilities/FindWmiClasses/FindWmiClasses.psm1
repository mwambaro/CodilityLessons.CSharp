<#
	Write a module that yields offline information about WMI namespaces and all
	WMI classes harboured therein. Hints:
		1. Get-WmiObject -List 
		2. Get-WmiObject -List -Namespace ROOT\StandardCimv2
#>

Function Write-WmiClassesDescriptionToFile 
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Object[]]
		$WmiClasses,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Namespace,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Path="$(Join-Path $Home "WmiClassesDescription.txt")"
	)

	if(Test-Path $Path -PathType Leaf) 
	{
		Remove-Item -Path $Path -ErrorAction SilentlyContinue
	}
	New-Item -Path $Home -Name "WmiClassesDescription.txt" -ItemType File | Out-Null

	$WmiClasses | Sort | % {
		$name = $_.ToString()
		if(-not ($name -Match "\A__")) 
		{
			try 
			{
				$class = [WmiClass]$name
				$class.PsBase.Options.UseAmendedQualifiers = $true
				$information = $class.PsBase.Qualifiers["Description"].Value 
				if([System.String]::IsNullOrEmpty($information))
				{
					throw "No description found."
				}
				Write-Output "`n$name [Namespace=$namespace]:`n`t$information" >> $Path
			}
			catch 
			{
				Write-Host -NoNewLine "$name"
				Write-Host -ForegroundColor Red " [FAILED]"
			}
		}
	}

} # Write-WmiClassesDescriptionToFile 

Function Get-AllWmiClasses 
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[Switch]
		$Description=$false,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Path="$(Join-Path $Home "WmiClassesDescription.txt")"
	) 

	$WmiClasses = @()
	# List classes under ROOT namespace
	$WmiClasses += (Get-WmiObject -List -Namespace root -ErrorAction SilentlyContinue).Name
	
	if($Description.IsPresent)
	{
		Write-WmiClassesDescriptionToFile -WmiClasses $WmiClasses -Namespace "Root"
	}

	# List all namespaces under ROOT namespace
	(Get-WmiObject -Namespace root __Namespace).Name | % {
    	# List all classes in every namespace under ROOT namespace
		$namespace = "Root\$($_)"
		$classes = (Get-WmiObject -List -Namespace $namespace -ErrorAction SilentlyContinue).Name
		
		if($Description.IsPresent)
		{
			Write-WmiClassesDescriptionToFile -WmiClasses $classes -Namespace $namespace
		}

		$WmiClasses += $classes
	}

	return $WmiClasses

} # Get-AllWmiClasses