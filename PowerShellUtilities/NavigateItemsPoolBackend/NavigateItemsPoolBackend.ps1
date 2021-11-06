
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

$ProgramDataPath = Join-Path "$Home" "AppData\Local\NavigateItemsPool"

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
		[System.String]$LogType='Error',
		[switch]$NoNewLine # Continue from previous line, if Verbose
	)

	$Function = "$($MyInvocation.MyCommand.Name)"

	try 
	{
		$MaxLogfileSize = 10Mb

		$ScriptFullName = & {$MyInvocation.ScriptName}
		$ScriptName = [System.String]::Empty
		if(-not [System.String]::IsNullOrEmpty($ScriptFullName))
		{
			$ScriptName = Split-Path -Leaf "$ScriptFullName"
		}

		$message = [System.String]::Empty
		if($LogType -eq 'Error')
		{
			$LineFeed = "`n"
			$message =  "$(Get-Date): $LineFeed"
			$message += "	Reason:      $($Exception.CategoryInfo.Reason) $LineFeed"
			$message += "	Function:    $Function $LineFeed"
			$message += "   Script:      $ScriptName $LineFeed"
			$message += "   Script line: $($Exception.InvocationInfo.ScriptLineNumber) $LineFeed"
			$message += "   Message:     $($Exception.Exception.Message) $LineFeed"
			$message += "	Line code:   $($Exception.InvocationInfo.Line)"
		}
		elseif($LogType -eq 'Verbose')
		{
			if($NoNewLine.IsPresent) 
			{
				$message = "$LogMessage"
			}
			else 
			{
				$message = "$(Get-Date): $LogMessage"
			}
		}
		else 
		{
			$message = "$(Get-Date): $LogMessage # $($ScriptName)"
		}
		
		$file = Join-Path "$ProgramDataPath" "data-log.log"
		$directory = Split-Path -Parent "$file"
		$leaf = Split-Path -Leaf "$file"
		
		if(-not (Test-Path "$directory" -PathType Container))
		{
			mkdir "$directory" | Out-Null
		}

		$lines = [System.Collections.Generic.List[string]]::new()
		$all = $null
		# Truncate log file
		if(Test-Path "$file" -PathType Leaf) 
		{
			if((Get-ItemProperty "$file").Length -gt $MaxLogfileSize) 
			{
				# Save last N lines
				$nToSave = 50
				$all = [System.IO.File]::ReadAllLines($file)
				$limit = $all.Count - $nToSave
				for($i=$limit; $i -gt $all.Count; $i++)
				{
					$lines.Add($all[$i])
				}
				# Delete log file
				Remove-Item "$file" | Out-Null
			}
		}

		# Handle NoNewLine 
		if($NoNewLine.IsPresent) 
		{
			if($all -eq $Null) 
			{
				$all = [System.IO.File]::ReadAllLines($file) 
			}

			if($all) 
			{
				$message = $all[-1] + $message
			}
		}

		# Write log data
		$lines.Add($message)
		[System.IO.File]::AppendAllLines($file, $lines) | Out-Null
	}
	catch 
	{
		Write-Output "$($Function): $($_.CategoryInfo.Reason); $($_.Exception.Message)"
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
			$date = Get-Date
			switch($messages.Count)
			{
				1 
				{
					$Data = @{
						Command = $messages[0].Trim();
						Date = $date
					}
				}
				2
				{
					$Data = @{
						Command = $messages[0].Trim();
						ItemCategory = $messages[1].Trim();
						Date = $date
					}
				}
				3
				{
					$Data = @{
						Command = $messages[0].Trim();
						ItemCategory = $messages[1].Trim();
						ItemSource = $messages[2].Trim();
						Date = $date
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

# <summary> 
#	Handles the 'Command.Interpreted' event and raises the 'Command.Executed' event to 
#	mark completion.
# </summary
# <details> 
#	The completion event is fired despite errors. It should be pointed out, though,
#   by adding a System.Exception object to the event arguments. 
# </details>
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
			Unregister-Event -SourceIdentifier $sub.SourceIdentifier | Out-Null
		}
	}

	# Subscribe to event 
	$x = Register-EngineEvent -SourceIdentifier $SourceIdentifier -Action {
		try 
		{
			# Harvest event data
			$SourceId = "Command.Executed"
			$params = $Args[0]
			$Command = $params.Command 
			$Category = $params.ItemCategory 
			$Source = $params.ItemSource
			$Date = $params.Date
			$Pipe = $params.Pipe
			[System.Exception]$Exception = $null

			# Put the data to use
			$message = "Command: $Command, Category: $Category, Source: $Source, Date: $Date"
			Write-Log -LogType 'Verbose' -LogMessage "$message"

			$EventArgs = @{
				Feedback = "$Command#$Category#$Source#$Date";
				Pipe = $Pipe;
				Exception = $Exception
			}
			$EventParams = @{
				SourceIdentifier = $SourceId;
				EventArguments = $EventArgs
			}

			$x = New-Event @EventParams
		}
		catch
		{
			Write-Log -Function $Function -Exception $_
		}
	}
} # Execute-CommandFromFrontend 

# <summary> Confirms to frontend execution of command </summary> 
# <details> 
#	Care must be taken to solve any race condition on the pipe since 
#   another write may be happening concurrently as a part of a possible 
#   other queued 'Command.Executed' event subscription. Feedback data 
#   field is formatted as follows: 'command#category#source#date'
# </details>
Function Confirm-ExecuteCommandToFrontend 
{
	[CmdletBinding()]
	param()

	$Function = $MyInvocation.MyCommand.Name
	$SourceIdentifier = "Command.Executed"

	# Remove events
	$subs = Get-EventSubscriber
	foreach($sub in $subs)
	{
		if($sub.SourceIdentifier -eq $SourceIdentifier)
		{
			Unregister-Event -SourceIdentifier $sub.SourceIdentifier | Out-Null
		}
	}

	# Subscribe to event
	$x = Register-EngineEvent -SourceIdentifier $SourceIdentifier -Action {
		try 
		{
			# Harvest event data
			$params = $Args[0]
			$Data = $params.Feedback
			$Pipe = $params.Pipe
			[System.Exception]$Exception = $params.Exception

			if($Pipe -eq $null) 
			{
				throw "Pipe object is null or invalid"
			}

			# Put the data to use
			$Feedback = [System.String]::Empty 
			if($Exception -eq $null) # OK
			{
				$Feedback = "OK#$Data"
			}
			else # ERROR
			{
				$Feedback = "ERROR#$Data"
			}
			WriteTo-ClientPipeStream -ServerPipe $Pipe -Feedback $Feedback | Out-Null
		}
		catch
		{
			Write-Log -Function $Function -Exception $_
		}
	}

} # Confirm-ExecuteCommandToFrontend 

# <summary> Writes to client pipe stream some feedback data </summary> 
# <param name="Feedback"> Feedback data to send to client pipe stream </param> 
# <details> 
#	No worries about blocking if it is called on a separate thread 
#	such as when called as part of an event handler script block. 
# </details>
Function WriteTo-ClientPipeStream 
{
	[CmdletBinding()]
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNull()]
		[System.IO.Pipes.NamedPipeServerStream]$ServerPipe,
		[ValidateNotNullOrEmpty()]
		[System.String]$Feedback="OK"
	)

	$Function = "$($MyInvocation.MyCommand.Name)"

	try 
	{
		Write-Log -LogType 'Verbose' -LogMessage "Waiting for incoming connection ... "
						
		# Check connection
		try 
		{
			if(-not $ServerPipe.IsConnected)
			{
				$ServerPipe.WaitForConnection() | Out-Null
			}
		}
		catch 
		{
			Write-Log -Function "$Function#WaitForConnection" -Exception $_
		}

		if($ServerPipe.IsConnected)
		{
			Write-Log -LogType 'Verbose' -LogMessage "OK" -NoNewLine 
			Write-Log -LogType 'Verbose' -LogMessage "Attempting write ... "
					    
			# Write data 
			$Encoding = [System.Text.Encoding]::UTF8 
			$Buffer = $Encoding.GetBytes($Feedback) 
			$PipeServer.Write($Buffer, 0, $Buffer.Count)

			Write-Log -LogType 'Verbose' -LogMessage "Done" -NoNewLine 
		}
	} 
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

} # WriteTo-ClientPipeStream

# <summary> Checks connection and reads data from client pipe stream </summary> 
# <param name="ServerPipe"> The pipe server stream </param>
# <return> The 'Command.Interpreted' event arguments data </return>
Function ReadFrom-ClientPipeStream 
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNull()]
		[System.IO.Pipes.NamedPipeServerStream]$ServerPipe
	) 

	$Function = "$($MyInvocation.MyCommand.Name)"
	$EventData = $null

	try 
	{
		Write-Log -LogType 'Verbose' -LogMessage "Waiting for incoming connection ... "
						
		# Check connection
		try 
		{
			if(-not $ServerPipe.IsConnected)
			{
				$ServerPipe.WaitForConnection() | Out-Null
			}
		}
		catch 
		{
			Write-Log -Function "$Function#WaitForConnection" -Exception $_
		}

		if($ServerPipe.IsConnected) 
		{
			Write-Log -LogType 'Verbose' -LogMessage "OK" -NoNewLine
			Write-Log -LogType 'Verbose' -LogMessage "Attempting read ... "
					    
			# Read data
			$Encoding = [System.Text.Encoding]::UTF8
			$BufferSize = 1024
			$Buffer = [byte[]]::new($BufferSize)
			$data = [System.String]::Empty
			$offset = 0
			$loop = $false
			do 
			{
				try 
				{
					$N = 0
					$Buffer = Initialize-Buffer -Buffer $Buffer
					$N = $ServerPipe.Read($Buffer, $offset, $Buffer.Count) 
					if($N -gt 0 -and $N -eq $Buffer.Count) # There may be more data to read
					{
						$offset = $N
						$loop = $false
						Write-Log -LogType 'Verbose' -LogMessage "OK [More data?] " -NoNewLine
					}
					else 
					{
						$loop = $false 
						$offset = 0
					}
				}
				catch 
				{
					Write-Log -Function "$Function#Read" -Exception $_
				}

				if($N -gt 0)
				{
					Write-Log -LogType 'Verbose' -LogMessage "OK" -NoNewLine
					
					$data += $Encoding.GetString($Buffer) 
				}
				else 
				{
					Write-Log -LogType 'Verbose' -LogMessage "EMPTY" -NoNewLine
				}
			}
			while($loop)

			$EventArgs = Interprete-PipeData -PipeData "$data"
			# Add pipe object
			$EventArgs["Pipe"] = $ServerPipe
			# Build splatted parameters for the event
			$EventParams = @{
				Sender = $ServerPipe;
				SourceIdentifier = $InterpretedEventSrcId;
				EventArguments = $EventArgs;
			}
			# Fire the event
			$x = New-Event @EventParams
			$EventData = $EventArgs
		}
		
	}
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

	return $EventData

} # ReadFrom-ClientPipeStream

# <summary> Interpretes and responds to a command from a frontend UI </summary>
# <details>
#	Can run as a background job, unless there are unwanted side effects. Provide 
#   for Inversion of Control (IoC) mechanism by firing a "Command.Interpreted" 
#   custom event. Wrap the needed data in the event arguments. 
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
			
				$PipeDirection = [System.IO.Pipes.PipeDirection]::InOut
				$ServerPipe = [System.IO.Pipes.NamedPipeServerStream]::new($ServerPipeName, $PipeDirection)

				if($ServerPipe)
				{
					Write-Log -LogType 'Verbose' -LogMessage "Server Pipe created."

					$loop = $true
					do 
					{
						$EvData = ReadFrom-ClientPipeStream -ServerPipe $ServerPipe
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


if(-not $LoadScript.IsPresent)
{
	Execute-CommandFromFrontend | Out-Null
	Confirm-ExecuteCommandToFrontend | Out-Null
	$ServerPipeName | Interprete-CommandFromFrontend
}