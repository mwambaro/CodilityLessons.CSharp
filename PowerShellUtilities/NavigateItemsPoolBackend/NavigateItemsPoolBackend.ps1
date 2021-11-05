
param
(
	[parameter(Mandatory=$true, ValueFromPipeline=$true)]
	[ValidateNotNullOrEmpty()]
	[System.String]$ServerPipeName,
	[switch]$LoadScript
)

<# Import data 
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.ps1', '.psd1'
$path = Join-Path "$here" "$sut"
. "$path"
#>

Function Write-Log 
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true)]
		$Exception,
		[System.String]$Function,
		[System.String]$LogMessage,
		[ValidateSet('Verbose', 'Error', 'Warning')]
		[System.String]$LogType='Error'
	)

	try 
	{
		$MaxLogfileSize = 10Mb

		$ScriptFullName = & {$MyInvocation.ScriptName}
		if([System.String]::IsNullOrEmpty($ScriptFullName))
		{
			$ScriptFullName = $MyInvocation.MyCommand.Path
		}
		if([System.String]::IsNullOrEmpty($ScriptFullName))
		{
			$ScriptFullName = Join-Path "$(Get-Location)" "script.ps1"
		}

		$ScriptName = "script.ps1"
		if(-not [System.String]::IsNullOrEmpty($ScriptFullName))
		{
			$ScriptName = Split-Path -Leaf "$ScriptFullName"
		}

		$message = [System.String]::Empty
		if($LogType -eq 'Error')
		{
			$message = "$(Get-Date): $Function; [$($Exception.CategoryInfo.Reason)] $($Exception.Exception.Message) # $($ScriptName)"
		}
		elseif($LogType -eq 'Verbose')
		{
			$message = "$(Get-Date): $LogMessage # $($ScriptName)"
		}
		else 
		{
			$message = "$(Get-Date): $LogMessage # $($ScriptName)"
		}
		
		$file = Join-Path "$Home" "AppData\Local\NavigateItemsPool\data-log.log"
		$directory = Split-Path -Parent "$file"
		$leaf = Split-Path -Leaf "$file"
		
		if(-not (Test-Path "$directory" -PathType Container))
		{
			mkdir "$directory" | Out-Null
		}

		# Truncate log file
		if(Test-Path "$file" -PathType Leaf) 
		{
			if((Get-ItemProperty "$file").Length -gt $MaxLogfileSize) 
			{
				Remove-Item "$file"
			}
		}

		# Write log data
		$lines = [System.Collections.Generic.List[string]]::new()
		$lines.Add($message)
		[System.IO.File]::AppendAllLines($file, $lines)
	}
	catch 
	{
		Write-Output "Write-Log: [$($_.CategoryInfo.Reason)] $($_.Exception.Message)"
	}

} # Write-Log 

# <summary> Interpretes data from client pipe according to its defined format </summary> 
# <param name="PipeData"> The formatted pipe data </param>
# <details>
#	Command comes from a client pipe stream structured as 
#	follows: 'Command#ItemCategory#ItemSource'.
# </details>
Function Interprete-PipeData
{
	[CmdletBinding()]
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$PipeData
	)

	$Function = "$($MyInvocation.MyCommand.Name)"
	$Data = $null

	try 
	{
		$PipeMessageSeparator = "#"
		$messages = $PipeData -Split "$PipeMessageSeparator"
		if($messages)
		{
			switch($messages.Count)
			{
				1 
				{
					$Data = @{Command = $messages[0].Trim()}
				}
				2
				{
					$Data = @{
						Command = $messages[0].Trim();
						ItemCategory = $messages[1].Trim()
					}
				}
				3
				{
					$Data = @{
						Command = $messages[0].Trim();
						ItemCategory = $messages[1].Trim();
						ItemSource = $messages[2].Trim()
					}
				}
			}
		}
	}
	catch
	{
		Write-Log -Function $Function -Exception $_
	}

	return $Data

} # Interprete-PipeData

Function Initialize-Buffer 
{
	[CmdletBinding()]
	param 
	(
		[byte[]]$Buffer
	)

	$Function = "$($MyInvocation.MyCommand.Name)"

	try 
	{
		if($Buffer)
		{
			if($Buffer.Count -gt 0) 
			{
				for($i=0; $i -lt $Buffer.Count; $i++) 
				{
					$Buffer += '0'
				}
			}
		}
	}
	catch
	{
		Write-Log -Function $Function -Exception $_
	}

	return $Buffer 

} # Initialize-Buffer

# <summary> Interpretes and responds to a command from a frontend UI </summary>
# <details>
#	Run as a background job. Provide for Inversion of Control (IoC) mechanism 
#   by firing a "Command.Interpreted" custom event. Wrap the needed data in the 
#   event arguments. 
# </details>
Function Interprete-CommandFromFrontend 
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$PipeName="ItemsPoolNavigationCommandPipe",
		[bool]$BackgroundJob=$false
	)

	$Function = "$($MyInvocation.MyCommand.Name)"

	try 
	{
		$ServerPipeName = $PipeName
		$InterpretedEventSrcId = "Command.Interpreted"
		$ExecutedEventSrcId = "Command.Executed"
		$JobName = "Interprete-Command"
	
		# Clean up any such-like jobs
		$job = Get-Job | Where {$_.Name -Match "\A$JobName\Z"}
		if($job)
		{
			Stop-Job -Job $job | Out-Null 
			Remove-Job -Job $job | Out-Null
		}
	
		$JobScriptBlock = {
			try 
			{
				Write-Log -LogType 'Verbose' -LogMessage "Starting Interpreter script block execution ..."
			
				$Encoding = [System.Text.Encoding]::UTF8
				$PipeDirection = [System.IO.Pipes.PipeDirection]::InOut
				$ServerPipe = [System.IO.Pipes.NamedPipeServerStream]::new($ServerPipeName, $PipeDirection)

				if($ServerPipe)
				{
					Write-Log -LogType 'Verbose' -LogMessage "Server Pipe created."

					$BufferSize = 1024
					$Buffer = [byte[]]::new($BufferSize)
					$loop = $true
					do 
					{
						Write-Log -LogType 'Verbose' -LogMessage "Waiting for incoming connection ..."
						
						# Connect
						try 
						{
							$ServerPipe.WaitForConnection() | Out-Null
						}
						catch 
						{
							Write-Log -Function "$Function#WaitForConnection" -Exception $_
						}

						Write-Log -LogType 'Verbose' -LogMessage "Connected. Attempting read ..."
					    
						# Read data
						$N = 0 
						try 
						{
							$Buffer = Initialize-Buffer -Buffer $Buffer
							$N = $ServerPipe.Read($Buffer, 0, $Buffer.Count)
						}
						catch 
						{
							Write-Log -Function "$Function#Read" -Exception $_
						}

						if($N -gt 0)
						{
							Write-Log -LogType 'Verbose' -LogMessage "Awesome! We got some data."
					
							$data = $Encoding.GetString($Buffer)
							$EventArgs = Interprete-PipeData -PipeData "$data"
							$EventParams = @{
								Sender = $ServerPipe;
								SourceIdentifier = $InterpretedEventSrcId;
								EventArguments = $EventArgs
							}
							$x = New-Event @EventParams
						}
						else 
						{
							Write-Log -LogType 'Verbose' -LogMessage "Yikes! No data read in."
						}
					}
					while($loop)

					Write-Log -LogType 'Verbose' -LogMessage "Done with interpreter main loop."
				}
				else 
				{
					Write-Log -LogType 'Verbose' -LogMessage "Could not create server pipe"
				}
			}
			catch
			{
				Write-Log -Function $Function -Exception $_
			}

			Write-Log -LogType 'Verbose' -LogMessage "Completing interpreter job script block."
		}

		if($BackgroundJob) 
		{
			$job = Start-Job -Name $JobName -ScriptBlock $JobScriptBlock
		}
		else 
		{
			. $JobScriptBlock | Out-Null
		}
	}
	catch
	{
		Write-Log -Function $Function -Exception $_
	}

} # Interprete-CommandFromFrontend


Function Execute-CommandFromFrontend 
{
	[CmdletBinding()]
	param()

	$Function = $MyInvocation.MyCommand.Name
	$SourceIdentifier = "Command.Interpreted"

	# Remove events
	$subs = Get-EventSubscriber
	foreach($sub in $subs)
	{
		if($sub.SourceIdentifier -eq $SourceIdentifier)
		{
			Unregister-Event -SourceIdentifier $sub.SourceIdentifier
		}
	}

	$x = Register-EngineEvent -SourceIdentifier $SourceIdentifier -Action {
		try 
		{
			$params = $Args[0]
			$Command = $params.Command 
			$Category = $params.ItemCategory 
			$Source = $params.ItemSource

			$message = "Command: $Command, Category: $Category, Source: $Source"
			Write-Log -LogType 'Verbose' -LogMessage "$message"
		}
		catch
		{
			Write-Log -Function $Function -Exception $_
		}
	}
}

if(-not $LoadScript.IsPresent)
{
	$ServerPipeName | Interprete-CommandFromFrontend
	Execute-CommandFromFrontend | Out-Null
}