<#
	Given Igor Pavlov 7zip application, given a research resources folder containing
	password-zipped files, given a search pattern as a regular expression (regex), find all 
	research resources that match the regex.
#>

Function Select-ResearchResources 
{
	[CmdletBinding()]
	[OutputType("System.String[]")]
	param 
	(
		[parameter(ValueFromPipeline=$true, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$ResearchResourcesFolder,
		[parameter(ValueFromPipeline=$true, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Pattern,
		[parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$7zipAppExecutableFullPath
	)

	$ResearchResources = @()

	try 
	{
		if([System.String]::IsNullOrEmpty($7zipAppExecutableFullPath)) 
		{
			$7zipAppExecutableFullPath = "C:\Program Files\7-Zip\7z.exe"
		}

		if(-not (Test-Path -Path $7zipAppExecutableFullPath -PathType Leaf))
		{
			throw [System.Exception]::new("App '$7zipAppExecutableFullPath' does not exist")
		}

		$ZipPattern = "(\.7z)\Z|(\.rar)\Z|(\.zip)\Z|(\.tar)\Z|(\.tar\.bz2)\Z|(\.tar\.gz)\Z"

		Get-ChildItem -Path $ResearchResourcesFolder -File -Recurse -ErrorAction SilentlyContinue | ? Name -Match $ZipPattern | % {

			if($_.Name -Match $Pattern) # The entire archive is a match
			{
				$ResearchResources += $_.FullName
			}
			else # Look inside the archive
			{
				# Repetition the "| ? Name -Match $ZipPattern" is more than enough
				if($_.Name -Match $ZipPattern) 
				{
					$contents = & $7zipAppExecutableFullPath l -r "$($_.FullName)"
					$indices = @()
					for($i=0; $i -lt $contents.Count; $i++) 
					{
						if($contents[$i] -Match "-{3,}")
						{
							$indices += $i 
							continue
						}
						if($indices.Count -lt 1 -and $indices.Count -gt 0) 
						{
							$file = ($contents[$i] -split " ")[-1].Trim()
							if(-not [Systemm.String]::IsNullOrEmpty($file)) 
							{
								if($file -Match $Pattern)
								{
									$ResearchResources += "$($_.FullName):$file"
								}
							}
						}
					}
				}
			}
		}

		Write-Progress	-Activity "Select Research Resources" -Completed
	}
	catch 
	{
		Write-Ouput $_
	}

	return $ResearchResources

} # Select-ResearchResources