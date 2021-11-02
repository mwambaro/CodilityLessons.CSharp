
param
(
	[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	[System.String[]]$VideosFolder
)

$VideosPoolPipe = $null
$AbortSourceIdentifier = "Ctrl_C_Pressed"

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

Function Handle-AbortEventFromCtrlC
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[ValidateNotNull()]
		[ScriptBlock]$Action
	)

	try
	{
		$SourceIdentifier = $AbortSourceIdentifier
		$EventName = "Abort Script"
		$Object = $MyInvocation

		Register-ObjectEvent -InputObject $Object -EventName $EventName -SourceIdentifier $SourceIdentifier -Action $Action
	}
	catch
	{
		Write-Output "Handle-AbortEventFromCtrlC: $_"
	}

} # Handle-AbortEventFromCtrlC

Function Fire-AbortEventFromCtrlC
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[ValidateNotNull()]
		[System.Management.Automation.Host.KeyInfo[]]$Keys
	)

	try
	{
		$SourceIdentifier = $AbortSourceIdentifier
		$Sender = $MyInvocation
		$Msg = "$($Keys.VirtualKeyCode -Join '+') were pressed."

		New-Event -SourceIdentifier $SourceIdentifier -Sender $Sender -EventArguments $Keys -MessageData $Msg
	}
	catch
	{
		Write-Output "Fire-AbortEventFromCtrlC: $_"
	}

} # Fire-AbortEventFromCtrlC

Function Catch-CtrlCKeys
{
	[CmdletBinding()]
	param()
	
	try
	{
		# Handle Ctrl + C
		$JobName = "Ctrl_C_Job"
		$job = Get-Job | Where {$_.Name -Match "$JobName"}
		if($job)
		{
			Stop-Job -Job $job | Out-Null
			Remove-Job -Job $job | Out-Null
		}

		$job = Start-Job -Name $JobName -ScriptBlock {
			$break_c = $true
			$Keys = @()
            do
            {
                $key1 = $host.UI.RawUI.ReadKey()
                $key2 = $host.UI.RawUI.ReadKey()
                if($key1.VirtualKeyCode -eq 17 -and $key2.VirtualKeyCode -eq 67)
                {
                    $break_c = $false
					$Keys += $key1
					$Keys += $key2
					# Fire Abort Event Handler
					Fire-AbortEventFromCtrlC -Keys $Keys | Out-Null
                }
            }
            while($break_c)
		}
	}
	catch
	{
		Write-Output "Catch-CtrlCKeys: $_"
	}	

} # Catch-CtrlCKeys


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
			$PipeDirection = [System.IO.Pipes.PipeDirection]::InOut
			$Pipe = $null
			try
			{
				$VideosPoolPipe = New-Object System.IO.Pipes.NamedPipeServerStream "VideoItemsPoolPipe", $PipeDirection
				$VideosPoolPipe.WaitForConnectionAsync()
				# Start Form UI
				$Exec = "D:\Data\Tutorials\Dot NET Core\Codility\CodilityLessons\NavigateItemsPoolForm\bin\Debug\NavigateItemsPoolForm.exe"
				Start-Process -FilePath "$Exec" | Out-Null

				# Register for Abort Event
				Handle-AbortEventFromCtrlC -Action {
					if(VideosPoolPipe)
					{
						$VideosPoolPipe.Close()
						$VideosPoolPipe.Dispose()
						Write-Output "Pipe gracefully disposed."
					}
				}
				# Handle Abort through Ctrl + C
				Catch-CtrlCKeys | Out-Null
			}
			catch
			{
				Write-Output "Exception: $_"
				if($VideosPoolPipe -ne $null)
				{
					$VideosPoolPipe.Close()
					$VideosPoolPipe.Dispose()
				}
				$VideosPoolPipe = $null
			}

			$Size = 1024
		
			do
			{
				$SortedItems | % {
					$Mname = $_.Name

					if(-not ($Mname -in $PlayedItems))
					{
						$Command = $null
						if($Pipe.IsConnected)
						{
							if($Pipe)
							{
								Write-Output "Buffer size: $($Size)"
							
								$buffer = [byte[]]::new($Size)
								$NRead = $VideosPoolPipe.Read($buffer, 0, $buffer.Count)
								if($NRead -eq $buffer.Count)
								{
									Write-Warning "May need more buffer space: {Read: $NRead; Buffer size: $($buffer.Count)}"
								}
								$Command = $Encoding.GetString($buffer)
								$buffer.Clear()
								$buffer = $null
							}

						}

						if([string]::IsNullOrEmpty($Command))
						{
							$Command = "Next"
						}
						
						$VideoFile = $null
						switch($Command)
						{
							"Next"
							{
								$VideoFile = $_.FullName
							}
							"Previous"
							{
								$VideoFile = $PlayedItems[$PlayedItems.Count-2]
							}
						}

						if(-not [string]::IsNullOrEmpty($VideoFile))
						{
							if(-not $ProcessExists)
							{
								if($Command -Match "Next")
								{
									Write-Output "$($Mname)" >> "$PlayedItemsPath"
								}
								$Process =  Start-Process -FilePath "$MediaPlayerPath" -ArgumentList """$VideoFile""", "--no-loop", "--no-repeat", "--no-qt-video-autoresize", "--fullscreen"
							}
							else
							{
								if($Command -Match "Previous")
								{
									if($Process)
									{
										Stop-Process -InputObject $Process | Out-Null
									}
									$Process =  Start-Process -FilePath "$MediaPlayerPath" -ArgumentList """$VideoFile""", "--no-loop", "--no-repeat", "--no-qt-video-autoresize", "--fullscreen"
								}
							}
						}
					}
				}

				$PlayedItems = [System.IO.File]::ReadAllLines($PlayedItemsPath)
			}
			while($VideosPoolPipe -ne $null)
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
