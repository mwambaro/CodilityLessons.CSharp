
param
(
	[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	[System.String[]]$VideosFolder
)

$VideosPoolPipe = $null
$AbortSourceIdentifier = "Ctrl_C_Pressed"
$PipeServerStreamPath = Join-Path $Home "_pipe_stream_object.xml"

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
		[ScriptBlock]$Action,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$SourceIdentifier
	)

	try
	{

		$Event = Get-EventSubscriber | Where {$_.SourceIdentifier -Match "\A$($SourceIdentifier)\Z"}
		if($Event)
		{
			Unregister-Event -SourceIdentifier $SourceIdentifier
		}

		Register-EngineEvent -SourceIdentifier $SourceIdentifier -Action $Action | Out-Null
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
		[System.Management.Automation.Host.KeyInfo[]]$Keys,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$SourceIdentifier
	)

	try
	{
		$Sender = $MyInvocation
		$Msg = "$($Keys.VirtualKeyCode -Join '+') were pressed."

		New-Event -SourceIdentifier $SourceIdentifier -Sender $Sender -EventArguments $Keys -MessageData $Msg | Out-Null
	}
	catch
	{
		Write-Output "Fire-AbortEventFromCtrlC: $_"
	}

} # Fire-AbortEventFromCtrlC

Function Catch-CtrlCKeys
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$SourceIdentifier
	)
	
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
					Fire-AbortEventFromCtrlC -Keys $Keys -SourceIdentifier $SourceIdentifier | Out-Null
                }

				"Key 1: $($key1); Key 2: $($key2) at $(Get-Date)" | Out-File "$(Join-Path $Home 'Ctrl_C_Keys.txt')"
            }
            while($break_c)
		}
	}
	catch
	{
		Write-Output "Catch-CtrlCKeys: $_"
	}	

} # Catch-CtrlCKeys

Function Create-NamedPipeServerStream
{
	[CmdletBinding()]
	[OutputType([System.IO.Pipes.NamedPipeServerStream])]
	param 
	(
		[System.String]$Path=$null,
		[System.String]$PipeName="VideoItemsPoolPipe"
	)

	$Pipe = $null

	try 
	{
		$Imported = $false 
		if([System.String]::IsNullOrEmpty($Path))
		{
			$Path = $PipeServerStreamPath
		}

		if(Test-Path "$Path")
		{
			$Pipe = (Import-Clixml -Path "$Path") -as [System.IO.Pipes.NamedPipeServerStream]
			if($Pipe)
			{
				Write-Output "Imported: $($Pipe.GetType().ToString())"
				$Imported = $true
			}

			# Register for PowerShell.Exiting event
			$x = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
				if(Test-Path "$Path")
				{
					Remove-Item "$Path" | Out-Null
				}
			}
		}
		
		
		if(-not $Imported)
		{
			$PipeDirection = $PipeDirection = [System.IO.Pipes.PipeDirection]::InOut
			$Pipe = New-Object System.IO.Pipes.NamedPipeServerStream $PipeName, $PipeDirection
			if($Pipe)
			{
				Export-Clixml -InputObject $Pipe -Path $Path | Out-Null
				Write-Output "Pipe exported to [$Path]"
			}
		}

		if($Pipe)
		{
			$Pipe.WaitForConnectionAsync() | Out-Null
		}
	}
	catch 
	{
		Write-Output "Create-NamedPipeServerStream: $_"
	}

	return $Pipe

} # Create-NamedPipeServerStream

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
				$VideosPoolPipe = [System.IO.Pipes.NamedPipeServerStream]::new("VideoItemsPoolPipe", $PipeDirection)
				if($null -eq $VideosPoolPipe)
				{
					throw "Failed to create pipe server stream"
				}

				$VideosPoolPipe.WaitForConnectionAsync()
				# Start Form UI
				$Exec = "D:\Data\Tutorials\Dot NET Core\Codility\CodilityLessons\NavigateItemsPoolForm\bin\Debug\NavigateItemsPoolForm.exe"
				Start-Process -FilePath "$Exec" | Out-Null

				# Handle Abort through Ctrl + C
				$SrcId = $AbortSourceIdentifier
				Catch-CtrlCKeys -SourceIdentifier $SrcId | Out-Null

				# Register for Abort Event
				$x = Handle-AbortEventFromCtrlC -SourceIdentifier $SrcId -Action {
					if($VideosPoolPipe)
					{
						$VideosPoolPipe.Close()
						$VideosPoolPipe.Dispose()
						Write-Output "Pipe gracefully disposed."
					}
				}
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
					$VFile = $_.FullName

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
								$VideoFile = $VFile
							}
							"Previous"
							{
								$VideoFile = $PlayedItems[$PlayedItems.Count-2]
							}
						}

						Write-Output "Video: $VideoFile"

						if(-not [string]::IsNullOrEmpty($VideoFile))
						{
							if(-not $ProcessExists)
							{
								if($Command -Match "Next")
								{
									Write-Output "$($Mname)" >> "$PlayedItemsPath"
								}
								$Process =  Start-Process -FilePath "$MediaPlayerPath" -ArgumentList """$VideoFile""", "--no-loop", "--no-repeat", "--no-qt-video-autoresize", "--fullscreen"
							
								break
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
								
									break
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

# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIzdUkCDSMd18SFIGhaYMo3IK
# 5qmgggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
# MB0xGzAZBgNVBAMTElBvd2VyU2hlbGxUZXN0Q2VydDAeFw0yMjAyMjcxOTExNTla
# Fw0zOTEyMzEyMzU5NTlaMB0xGzAZBgNVBAMTElBvd2VyU2hlbGxUZXN0Q2VydDCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN1YNAY2pgeItqmLMdFyobcb
# G+I6bkuMYZ8IznGja9fjm5T6Y2B6hk/HC6qZdQkO5bVlVRbUDI+rTzmb+E9oaQTB
# uxHkVoUDf4cwdRTXQutwAMNXjSr7Qu3TWq9zSHoB4IIotsBDLcMRETn0N2+NQCpu
# zAx6mpfR8wSx4MUCfrWou91wi3yi+3jnAjEesSxDixIbBquMJILuw2dXfIa5Smmz
# WIRYbwRZhmu5XYO4TMzb8wL7j9xvgZ7hDkSFVtO/XRx8Xo0jqHOKvAeq7FRzJsbA
# CHVkFyxIEsPRJnA55Ipj8fQv+jz8RwfqnOuGQdNa+QduIZDhygRk2FZQ6zY4HC0C
# AwEAAaNnMGUwEwYDVR0lBAwwCgYIKwYBBQUHAwMwTgYDVR0BBEcwRYAQPXZnVQiW
# Kce5l+EFSkh7saEfMB0xGzAZBgNVBAMTElBvd2VyU2hlbGxUZXN0Q2VydIIQUvb4
# 71+fFaJF8jxZ844o0jAJBgUrDgMCHQUAA4IBAQAw4dsZ82GVIVCcdHUHOCM0L8xI
# LbeXMcBEkoERmg7LZCxXjJdhEkFmp/DdqIHuPdocezzaE2QPtrNVuehVgDr9QB2b
# dwbbp0vrOUowWYibzNzFzAHjF4lDdgytivAITdwpVX8tl9vxKgJa4YVFz83B4BdB
# hH44DrF/y0Sm/XOSkqFt6EjLuPCjMiNDbiQHm8Ch5mv6lMCJYctA/QouTXvEXMy9
# RWL5PFM6NNWy/nvQBVDrp2RVxUojFCVw0dfw/PE0a0wsk7iLDQZpIFplqSACunEA
# SyUSpTg/M1S3ZasW0riSJA3NBlBvXnx9l1jGYRa8YfcyTjohTOBunl8Dyy1dMYIB
# 0jCCAc4CAQEwMTAdMRswGQYDVQQDExJQb3dlclNoZWxsVGVzdENlcnQCEFL2+O9f
# nxWiRfI8WfOOKNIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHkBOgdVKiV9VC7SW1ixxcsv2je6
# MA0GCSqGSIb3DQEBAQUABIIBAAs9+f/+uA2aKxc5TpCi1A9PHgIaUgjYc2vmKEB2
# Vga9jloTJhvdoxBtJD+p1+qjLMT7MjSMfFRdk8i0RSigX1K0Q7wyb2I8zt5kvWSK
# UJwHhWsQglWZRh5QjHivNsSyiR3kEktK4plNPiCQcv+tHG/d1sQYK4SJjeys3d3y
# Yg+M95vymjspgOMZcrjkYfhLOUFFy4OdbwnZUwV5VEqNWy0T8mGTMTOpaeUls6UB
# hiv9MnJUcSYsywxkDckSOvqMffBWteD5mYNYn2b1UXNuHhymML/BO8EL4cjeqsi3
# aDNBhEGixGNuB5VOXR391KkKI+WDtk76ZEXXmjHoYT/x4l0=
# SIG # End signature block
