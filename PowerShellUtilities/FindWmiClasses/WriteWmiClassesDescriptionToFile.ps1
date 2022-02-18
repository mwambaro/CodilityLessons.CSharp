
$WriteWmiClassesDescriptionToFile = {
	param
	(
		$WmiClasses,
		$Namespace
	)

	$WmiClassesDescriptionFile = "WmiClassesDescription.txt"

	$WmiClasses | Sort | % {
		$name = $_.ToString()
		if(-not ($name -Match "\A__")) 
		{
			try 
			{
				$class = [WmiClass]$name
				$class.PsBase.Options.UseAmendedQualifiers = $true
				
				# class
				$information = $class.PsBase.Qualifiers["Description"].Value 
				if([System.String]::IsNullOrEmpty($information))
				{
					$information = [System.String]::Empty 
				}
				else 
				{
					$information = "`n$name [Namespace=$Namespace]:`n`t$information`n`n`tProperties:`n"
				}
				# Properties
				$counter = 0
				($class.PsBase.Properties).Name | Sort | % {
					$property = $_
					$value = $class.PsBase.Properties[$property].Qualifiers["Description"].Value
					if(-not [System.String]::IsNullOrEmpty($value))
					{
						$counter += 1
						$information = "$information`n`t$($counter). $($property): $($value)"
					}
				}
				# Methods
				if(-not [System.String]::IsNullOrEmpty($information))
				{
					$information = "$information`n`n`tMethods:`n"
				}
				$counter = 0
				($class.PsBase.Methods).Name | Sort | % {
					$method = $_
					$value = $class.PsBase.Methods[$method].Qualifiers["Description"].Value
					if(-not [System.String]::IsNullOrEmpty($value))
					{
						$counter += 1
						$information = "$information`n`t$($counter). $($method): $($value)"
					}
				}

				if([System.String]::IsNullOrEmpty($information))
				{
					throw "No description found."
				}
				$Path = Join-Path $Home $WmiClassesDescriptionFile
				Write-Output "$information" >> $Path
			}
			catch 
			{
				Write-Host -NoNewLine "$name"
				Write-Host -ForegroundColor Red " [FAILED]"
			}
		}
	}

} # WriteWmiClassesDescriptionToFile code block

# List all classes in ROOT namespace
$namespace = "Root"
$WmiClasses = (Get-WmiObject -List -Namespace $namespace -ErrorAction SilentlyContinue).Name

# Get the WMI classes description
& $WriteWmiClassesDescriptionToFile $WmiClasses $namespace

# List every namespace under ROOT namespace
(Get-WmiObject -Namespace root __Namespace).Name | % {
    # List all classes in every namespace under ROOT namespace
	$namespace = "Root\$($_)"
	$WmiClasses = (Get-WmiObject -List -Namespace $namespace -ErrorAction SilentlyContinue).Name
	
	# Get the WMI classes description
	& $WriteWmiClassesDescriptionToFile $WmiClasses $namespace
}