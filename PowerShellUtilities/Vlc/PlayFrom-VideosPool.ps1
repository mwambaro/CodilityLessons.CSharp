
param
(
	[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	[System.String[]]$VideosFolder
)

# <summary> Gets the specific installed application(s) from amongst all installed Apps </summary>
# <param name="DisplayName"> The display name(s) of the sought App(s) </param>
# <return> The App(s) Item Property object(s) </return>
Function Get-InstalledApplication
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[System.String[]]$DisplayName
	)

	# Build the Apps Regex pattern
	$Matcher = ""
	if($DisplayName.Count -gt 1)
	{
		for($i=0; $i -lt $DisplayName.Count; $i++) 
		{
			if($i -lt ($DisplayName.Count-1))
			{
				$Matcher += "(${DisplayName[$i]})|"
			}
			else
			{
				$Matcher += "(${DisplayName[$i]})"
			}
		}
	}
	else
	{
		$Matcher = "${DisplayName}"
	}

	# Get the App(s)
	$Items = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall 
	$AppItem = $Items | % {Get-ItemProperty $_.PsPath} | Where {$_.DisplayName -Match $Matcher}

	return $AppItem
}


# <summary> Plays a video file from a pool of videos, one unique video at a time </summary>
# <param name="SourceFolder"> Folder(s) path to the videos pool </param>
# <return> Media player process </return>
Function PlayFrom-VideosPool
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[System.String[]]$SourceFolder
	)

	$Process = $null

	try
	{

		# Read in played items
		$PlayedItemsPath = Join-Path $Home "VideosPoolPlayedItems.txt"
		$PlayedItems = $null
		if(Test-Path $PlayedItemsPath)
		{
			$PlayedItems = [System.IO.File]::ReadAllLines($PlayedItemsPath)
		}

		# Get Items to play
		$Items = $SourceFolder | Get-ChildItem -File -Recurse | Select Name, FullName, @{label="Size";expression={$_.Length}}
	
		# Check Media Process Existence
		$MediaProcess = "vlc"
		$ProcessExists = $false
		$Process = Get-Process $MediaProcess -ErrorAction SilentlyContinue 
		if($Process)
		{
			$Process | % {
				$proc = $_
				$ii = $proc.MainWindowTitle.LastIndexOf("-")
				$PlayingItem = $proc.MainWindowTitle.Substring(0, $ii).Trim()
				if($Items)
				{
					if($PlayingItem -in $Items.Name)
					{
						$ProcessExists = $true
						$Process = $proc
					}
				}
			}
		}

		if($ProcessExists)
		{
			#return $Process
		}

		# Sort by size, decreasing
		$SortedItems = $Items | Sort -Property Size -Descending

		# Play first not-yet-played item
		$MediaPlayerName = "vlc"
		$MediaPlayerItem = Get-InstalledApplication -DisplayName $MediaPlayerName
		if($MediaPlayerItem)
		{
			$MediaPlayerPath = Join-Path $MediaPlayerItem.InstallLocation "vlc.exe"
			Write-Output $MediaPlayerPath

			$Encoding = [System.Text.Encoding]::UTF8
			$PipeDir = [System.IO.Pipes.PipeDirection]::InOut
			$Pipe = New-Object System.IO.Pipes.NamedPipeServerStream "VideosPool"
			$Pipe.WaitForConnectionAsync()
			$Size = 1024
		
			# Start Form UI
			$Exec = "D:\Data\Tutorials\Dot NET Core\Codility\CodilityLessons\NavigateItemsPoolForm\bin\Debug\NavigateItemsPoolForm.exe"
			Start-Process -FilePath "$Exec" | Out-Null
		
			while($true)
			{
				$SortedItems | % {
					if(-not ($_.Name -in $PlayedItems))
					{
						if($Pipe.IsConnected)
						{
							$Command = $null

							Write-Output "Buffer size: $($Size)"
							
							$buffer = [byte[]]::new($Pipe.InBufferSize)
							$NRead = $Pipe.Read($buffer, 0, $buffer.Count)
							if($NRead -eq $buffer.Count)
							{
								Write-Warning "May need more buffer space: {Read: $NRead; Buffer size: $($buffer.Count)}"
							}
							$Command = $Encoding.GetString($buffer)
							$buffer.Clear()
							$buffer = $null

							if([string]::IsNullOrEmpty($Command))
							{
								break
							}

							Write-Output "Command: $Command"
						
							$VideoFile = $null
							switch($Command)
							{
								"Next"
								{
									Write-Output "$($_.Name)" >> "$PlayedItemsPath"
									$VideoFile = $_.FullName
								}
								"Previous"
								{
									$VideoFile = $PlayedItems[$PlayedItems.Count-2]
								}
							}

							if(-not [string]::IsNullOrEmpty($VideoFile))
							{
								if($Process)
								{
									Stop-Process -InputObject $Process | Out-Null
								}
								$Process =  Start-Process -FilePath "$MediaPlayerPath" -ArgumentList """$VideoFile""", "--no-loop", "--no-repeat", "--no-qt-video-autoresize", "--fullscreen"
							}
							break
						}
						else
						{
							Write-Output "Pipe not connected."
						}
					}
				}

				$PlayedItems = [System.IO.File]::ReadAllLines($PlayedItemsPath)

				sleep 2
			}
		}
		else
		{
			Write-Verbose "Did not find ${MediaPlayerName} App."
		}
	}
	catch
	{
		Write-Output "PlayFrom-VideosPool: $($_)"
	}
	finally
	{
		if($Pipe)
		{
			$Pipe.Close()
			$Pipe.Dispose()
		}
	}

	return $Process

}

if($VideosFolder)
{
	$VideosFolder | PlayFrom-VideosPool
}
