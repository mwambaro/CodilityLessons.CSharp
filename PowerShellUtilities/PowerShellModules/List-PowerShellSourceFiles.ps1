
param(
	[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	[Switch]$Run
)

$Script:TotalEntryCount = 100
$Script:EntryCount = 1
$Script:Activity = "Listing PowerShell Source Files For Display in Code Editor"


#########################################################
# Display-ProgressBar is a helper function used to 
# used to display progress message. 
#########################################################
Function Display-ProgressBar
{
    param 
    (
        [string] $cmdletName,
        [string] $status,
        [double] $previousSegmentWeight,
        [double] $currentSegmentWeight,
        [int]    $totalNumberofEntries,
        [int]    $currentEntryCount
    )

    if($cmdletName -eq $null) { throw "CmdletName not given" }
    if($status -eq $null) { throw "Status not given" }

    if($currentEntryCount -gt 0 -and 
       $totalNumberofEntries -gt 0 -and 
       $previousSegmentWeight -ge 0 -and 
       $currentSegmentWeight -gt 0)
    {
        $entryDefaultWeight = $currentSegmentWeight/[double]$totalNumberofEntries
        $percentComplete = $previousSegmentWeight + ($entryDefaultWeight * $currentEntryCount)
        Write-Progress -Activity $cmdletName -Status $status -PercentComplete $percentComplete 
    }
} # Display-ProgressBar

Function Get-PSSourceFilesDirectories
{
	# We just rely on the assumption that the modules paths are console-output.
	# Why, Get-Module CmdLet output object cannot tell us search directories, can it?
	
	# Progress bar
	$Script:EntryCount += 4
	$PrevSegW = 0
	$CurrentSegW = 100
	Display-ProgressBar $Script:Activity "Get-PSSourceFilesDirectories: Leveraging Get-Module CmdLet" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount

	$OutFile = Join-Path $Home "PSModulesList.txt"
	Get-Module -ListAvailable -All > "$OutFile"

	# Progress bar
	$Script:EntryCount =+ 25
	$CurrentSegW = 100
	Display-ProgressBar $Script:Activity "Get-PSSourceFilesDirectories: Processing Get-Module CmdLet Output" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount

	$Directories = @()
	$ToSkip = @()
	$Lines = [System.IO.File]::ReadAllLines($OutFile)
	
	$ProgressBarStep = [System.Math]::Floor($Lines.Count/($Script:TotalEntryCount - $Script:EntryCount - 60))
	
	for($i=0; $i -lt $Lines.Count; $i++)
	{
		# Progress bar
		if(0 -eq ($i % $ProgressBarStep))
		{
			$Script:EntryCount =+ 1
		}
		Display-ProgressBar $Script:Activity "Get-PSSourceFilesDirectories: Processing line $i" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount
		
		if([System.String]::IsNullOrEmpty($Lines[$i]))
		{
			continue
		}

		$regex = "\A\s*directory\s*:\s*(.+)"
		if($Lines[$i] -Match $regex)
		{
			#Write-Output "Quelle horreur: $($Lines[$i])"
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
				#Write-Output "Quelle horreur: $($Lines[$j])"
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

Function List-PSSourceFiles
{
	$ScriptsH = $null
	$ModulesH = $null
	$Modules = @()
	$Scripts = @()
	$Dirs = Get-PSSourceFilesDirectories

	# Progress bar
	$PrevSegW = 0
	$CurrentSegW = 100
	$RemCount = [System.Math]::Floor(($Script:TotalEntryCount-$Script:EntryCount) / $Dirs.Count)
	Display-ProgressBar $Script:Activity "List-PSSourceFiles: Searching Module Directories" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount
	
	foreach($dir in $Dirs)
	{	
		$Items = $dir | Get-ChildItem -File -Recurse | Sort -Property Name

		$ProgressBarStep = [System.Math]::Floor($Items.Count/($Script:TotalEntryCount - $Script:EntryCount - $RemCount))
		
		$i = 0
		foreach($item in $Items)
		{
			# Progress bar
			if(0 -eq ($i % $ProgressBarStep))
			{
				$Script:EntryCount =+ 1
			}
			Display-ProgressBar $Script:Activity "List-PSSourceFiles: PS Item [$($item.Name)]" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount
			
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

Function Write-PSSourceFilesForDisplay
{
	[CmdLetBinding()]
	param(
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[System.Collections.Hashtable[]]$SourceFiles,
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[ValidateSet('Module', 'Script')]
		[System.String]$SourceType
	)

	# Progress bar
	$Script:EntryCount += 2
	$PrevSegW = 0
	$CurrentSegW = 100
	Display-ProgressBar $Script:Activity "Write-PSSourceFilesForDisplay: Parsing sources" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount

	# For Progress bar
	$ItemsCount = 0
	foreach($sources in $SourceFiles)
	{
		$ItemsCount += $sources.Values.Count
	}
	$ProgressBarStep = [System.Math]::Floor($ItemsCount/($Script:TotalEntryCount - $Script:EntryCount))

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

			# Progress bar
			if(0 -eq ($Counter % $ProgressBarStep))
			{
				$Script:EntryCount =+ 1
			}
			Display-ProgressBar $Script:Activity "Write-PSSourceFilesForDisplay: Writing source files names from [$dir] to [$File]" $PrevSegW $CurrentSegW $Script:TotalEntryCount $Script:EntryCount

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

Function Display-PSSourceFilesList
{
	[CmdLetBinding()]
	param(
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
		$EditorExecPath = "$Home\AppData\Local\Programs\Microsoft VS Code\Code.exe"
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
				return $AppItem
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
