
param
(
	[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	[Switch]$Run
)

$Script:TotalEntryCount = 100
$Script:EntryCount = 1
$Script:Activity = "Listing PowerShell Source Files For Display in Code Editor"


# <summary> Displays progress bar for an activity given current entry count </summary>
# <param name="Activity"> Activity name or id for which we need progress bar </param>
# <param name="Status"> Activity progression status information </param>
# <param name="CurrentEntryCount"> The current progression point in entries count </param>
# <param name="TotalNumberOfEntries"> The total number of entries. You can go beyond the default 100 </param>
Function Display-ProgressBar
{
    [CmdLetBinding()]
	param 
    (
        [parameter(Mandatory=$false, Position=1)]
		[ValidateNotNullOrEmpty()]
		[string] $Activity,
		[parameter(Mandatory=$false, Position=2)]
		[ValidateNotNullOrEmpty()]
        [string] $Status,
		[parameter(Mandatory=$false, Position=3)]
        [int]    $CurrentEntryCount,
		[parameter(Mandatory=$false, Position=4)]
        [int]    $TotalNumberofEntries=100
    )

    $PercentComplete = [System.Math]::Floor(($CurrentEntryCount/$TotalNumberOfEntries)%100)
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete 

} # Display-ProgressBar

# <summary> Finds directories where PowerShell modules and scripts are located </summary>
# <return> An array of PowerShell modules and scripts sources directories </return>
# <details>
#	We just rely on the assumption that the modules paths are console-output.
#	Why, Get-Module CmdLet output object cannot tell us search directories, can it?
# </details>
Function Get-PSSourceFilesDirectories
{
	[CmdLetBinding()]
	param 
	(
		[switch]$ProgressBar=$false
	)

	if(-not [System.String]::IsNullOrEmpty($env:PSModulePath))
	{
		return $env:PSModulePath.Split(";")
	}
	
	if($ProgressBar)
	{
		$Script:EntryCount += 4
		Display-ProgressBar -Activity $Script:Activity -Status "Get-PSSourceFilesDirectories: Leveraging Get-Module CmdLet" -CurrentEntryCount $Script:EntryCount
	}

	$OutFile = Join-Path $Home "PSModulesList.txt"
	Get-Module -ListAvailable -All > "$OutFile"

	if($ProgressBar)
	{
		$Script:EntryCount =+ 25
		Display-ProgressBar -Activity $Script:Activity -Status "Get-PSSourceFilesDirectories: Processing Get-Module CmdLet Output" -CurrentEntryCount $Script:EntryCount
	}

	$Directories = @()
	$ToSkip = @()
	$Lines = [System.IO.File]::ReadAllLines($OutFile)
	
	$ProgressBarStep = [System.Math]::Floor($Lines.Count/($Script:TotalEntryCount - $Script:EntryCount - 60))
	
	for($i=0; $i -lt $Lines.Count; $i++)
	{
		if($ProgressBar)
		{
			if(0 -eq ($i % $ProgressBarStep))
			{
				$Script:EntryCount =+ 1
			}
			Display-ProgressBar -Activity $Script:Activity -Status "Get-PSSourceFilesDirectories: Processing line $i" -CurrentEntryCount $Script:EntryCount
		}

		if([System.String]::IsNullOrEmpty($Lines[$i]))
		{
			continue
		}

		$regex = "\A\s*directory\s*:\s*(.+)"
		if($Lines[$i] -Match $regex)
		{
			continue
		}
		if([System.String]::IsNullOrEmpty($Matches[1]))
		{
			continue
		}

		$line = $Matches[1].Trim()

		# Skip if it is a subdirectory somewhere
		if($line -in $ToSkip)
		{
			continue
		}

		# Fetch any subdirectories
		$subdirs = Get-ChildItem "$line" -Directory -Recurse
		if($subdirs)
		{
			foreach($dir in $subdirs)
			{
				$ToSkip += $dir.FullName
			}
		}

		$lregex = [System.Text.RegularExpressions.Regex]::Escape($line)
		for($j=$i+1; $j -lt $Lines.Count; $j++)
		{
			if([System.String]::IsNullOrEmpty($Lines[$j]))
			{
				continue
			}

			$match = $Lines[$j] -Match $regex
			if(-not $match)
			{
				continue
			}
			if([System.String]::IsNullOrEmpty($Matches[1]))
			{
				continue
			}

			$dline = $Matches[1].Trim()
			if($dline -Match "\A$lregex")
			{
				if(-not ($line -in $Directories))
				{
					$Directories += $line
				}
			}
		}
	}

	if(Test-Path "$OutFile")
	{
		Remove-Item "$OutFile" | Out-Null
	}

	return $Directories

} # Get-PSSourceFilesDirectories

# <summary> Scans for PowerShell modules and scripts source files </summary>
# <return> 
#	A list of modules hash table, scripts hash table, and sources directories, 
#	respectively 
# </return>
# <details>
#	The hash tables have source directories as keys and source file 
#	full paths in values
# </details>
Function List-PSSourceFiles
{
	[CmdLetBinding()]
	param 
	(
		[switch]$ProgressBar=$false
	)

	$ScriptsH = $null
	$ModulesH = $null
	$Modules = @()
	$Scripts = @()
	$Dirs = Get-PSSourceFilesDirectories

	if($ProgressBar)
	{
		$RemCount = [System.Math]::Floor
		(
			($Script:TotalEntryCount-$Script:EntryCount) / $Dirs.Count
		)
		Display-ProgressBar -Activity $Script:Activity -Status "List-PSSourceFiles: Searching Module Directories" -CurrentEntryCount $Script:EntryCount
	}

	foreach($dir in $Dirs)
	{	
		if(!(Test-Path $dir -PathType Container))
		{
			continue
		}

		$Items = $dir | Get-ChildItem -File -Recurse | Sort -Property Name

		$ProgressBarStep = [System.Math]::Floor
		(
			$Items.Count/($Script:TotalEntryCount - $Script:EntryCount - $RemCount)
		)
		
		$i = 0
		foreach($item in $Items)
		{
			if($ProgressBar)
			{
				if(0 -eq ($i % $ProgressBarStep))
				{
					$Script:EntryCount =+ 1
				}
				Display-ProgressBar -Activity $Script:Activity -Status "List-PSSourceFiles: PS Item [$($item.Name)]" -CurrentEntryCount $Script:EntryCount
			}

			if($item.FullName -Match "\.ps\d\Z")
			{
				$Scripts += $item.FullName
			}
			elseif($item.FullName -Match "\.psm\d\Z")
			{
				$Modules += $item.FullName
			}

			$i++
		}
		
		if($Modules)
		{
			if($Modules.Count -eq 0)
			{
				continue
			}
			if($ModulesH -eq $null)
			{
				$ModulesH = New-Object System.Collections.Hashtable
			}
			$ModulesH.Add("$dir", $Modules)
			$Modules = @()
		}
		if($Scripts)
		{
			if($Scripts.Count -eq 0)
			{
				continue
			}
			if($ScriptsH -eq $null)
			{
				$ScriptsH = New-Object System.Collections.Hashtable
			}
			$ScriptsH.Add("$dir", $Scripts)
			$Scripts = @()
		}
	}

	return $ModulesH, $ScriptsH, $Dirs

} # List-PSSourceFiles

# <summary> Writes source file paths to files according to the origin directories </summary>
# <return> An array of output files to which the source file paths were written </return>
Function Write-PSSourceFilesForDisplay
{
	[CmdLetBinding()]
	param
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[System.Collections.Hashtable[]]$SourceFiles,
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[ValidateSet('Module', 'Script')]
		[System.String]$SourceType,
		[switch]$ProgressBar=$false
	)

	if($ProgressBar)
	{
		$Script:EntryCount += 2
		Display-ProgressBar -Activity $Script:Activity -Status "Write-PSSourceFilesForDisplay: Parsing sources" -CurrentEntryCount $Script:EntryCount
	}

	# For Progress bar
	$ItemsCount = 0
	foreach($sources in $SourceFiles)
	{
		$ItemsCount += $sources.Values.Count
	}
	$ProgressBarStep = [System.Math]::Floor
	(
		$ItemsCount/($Script:TotalEntryCount - $Script:EntryCount)
	)

	$PSSourceFilesListFiles = @()
	foreach($sources in $SourceFiles)
	{
		$dirs = ($sources.Keys).Split("`n")
		$FileCore = "$($SourceType)sToReview"
		for($i=0; $i -lt $dirs.Count; $i++)
		{
			if($i -lt 1)
			{
				$File = Join-Path $Home "$FileCore.txt"
			}
			else 
			{
				$File = Join-Path $Home "$FileCore-$i.txt"
			}

			if(Test-Path "$File")
			{
				Remove-Item "$File"
			}

			$dir = $dirs[$i].Trim()

			if($ProgressBar)
			{
				if(0 -eq ($Counter % $ProgressBarStep))
				{
					$Script:EntryCount =+ 1
				}
				Display-ProgressBar -Activity $Script:Activity -Status "Write-PSSourceFilesForDisplay: Writing source files names from [$dir] to [$File]" -CurrentEntryCount $Script:EntryCount
			}

			$dirregex = [System.Text.RegularExpressions.Regex]::Escape($dir)
			if($sources.ContainsKey($dir))
			{
				$PSSourceFilesListFiles += $File
				Write-Output "PSHome: $dir" >> "$File"
				Write-Output " " >> "$File"
				Write-Output " " >> "$File"

				$srcFiles = $sources.Item("$dir")
				foreach($source in $srcFiles)
				{
					$leaf = $source.Substring($dir.Length)
					Write-Output "{PSHome}$($leaf)" >> "$File"
				}
			}
		}
	}

	Write-Progress -Activity $Script:Activity -Completed

	return $PSSourceFilesListFiles

} # Write-PSSourceFilesForDisplay

# <summary> Displays PowerShell source files paths in a code editor </summary>
# <return> The source code editor process object </return>
Function Display-PSSourceFilesList
{
	[CmdLetBinding()]
	param
	(
		[parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[System.String]$EditorExecPath=$null
	)

	$modules, $scripts, $dirs = List-PSSourceFiles

	# Write PS Source Files names to files, for display
	$ListFiles = Write-PSSourceFilesForDisplay -SourceFiles $modules -SourceType "Module"
	$ListFiles1 = Write-PSSourceFilesForDisplay -SourceFiles $scripts -SourceType "Script"
	if($ListFiles1)
	{
		foreach($f in $ListFiles1)
		{
			if($ListFiles){ $ListFiles += $f }
		}
	}
	
	if(-not $ListFiles)
	{
		return $null
	}

	# Turn them into well-formatted powershell path strings
	for($i=0; $i -lt $ListFiles.Count; $i++)
	{
		$ListFiles[$i] = """$($ListFiles[$i])"""
	}

	# Set default to 'Visual Studio Code'
	if([System.String]::IsNullOrEmpty($EditorExecPath))
	{
		$EditorExecPath = Join-Path $Home "AppData\Local\Programs\Microsoft VS Code\Code.exe"
	}
	
	$Process = $null
	if(-not [System.String]::IsNullOrEmpty($EditorExecPath) -and (Test-Path "$EditorExecPath"))
	{
		$Process =  Start-Process -FilePath "$EditorExecPath" -ArgumentList $ListFiles
	}
	else
	{
		# TODO: Test this block of code against the editors
		# Get Source Code Editor: VS Code, Notepad++, MS Visual Studio, Notepad.exe
		$here = Split-Path -Parent $MyInvocation.MyCommand.Path
		$UtilsDir = Split-Path -Parent "$here"
		. "$UtilsDir\Vlc\PlayFrom-VideosPool.ps1" # Import Get-InstalledApplication
	
		$Editors = @("Visual Studio Code", "Notepad++", "Microsoft Visual Studio", "Notepad")
		$AppItem = $Editors | Get-InstalledApplication
		if($AppItem)
		{
			$EditorPath = $AppItem[0].DisplayIcon
			if(-not (Test-Path "$EditorPath"))
			{
				Write-Output "Editor: $($AppItem[0].DisplayName) could not be found"
				return $null
			}
			Write-Output $EditorPath
			$EditorExecPath = $EditorPath
		}
	}

	return $Process

} # Display-PSSourceFilesList

if($Run.IsPresent)
{
	$Process = Display-PSSourceFilesList
	return $Process
}
