

$ProgramDataPath = Join-Path $Home "AppData\Local\NavigateItemsPool"
$PipeWriteJobs = [System.Collections.Generic.List[System.Object]]::new()

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

	$FunctionName = $MyInvocation.MyCommand.Name

	try 
	{
		$MaxLogfileSize = 10Mb

		$ScriptFullName = & {$MyInvocation.ScriptName}
		$ScriptName = [System.String]::Empty
		if(-not [System.String]::IsNullOrEmpty($ScriptFullName))
		{
			$ScriptName = Split-Path -Leaf $ScriptFullName
		}

		$message = [System.String]::Empty
		if($LogType -eq 'Error')
		{
			$LineFeed = "`n"
			$message =  "$(Get-Date): $LineFeed"
			$message += "    Reason:      $($Exception.CategoryInfo.Reason) $LineFeed"
			$message += "    Function:    $Function $LineFeed"
			$message += "    Script:      $ScriptName $LineFeed"
			$message += "    Script line: $($Exception.InvocationInfo.ScriptLineNumber) $LineFeed"
			$message += "    Line code:   $($Exception.InvocationInfo.Line.Trim()) $LineFeed"
			$message += "    Message:     $($Exception.Exception.Message)"
		}
		elseif($LogType -eq 'Verbose')
		{
			if($NoNewLine.IsPresent) 
			{
				$message = $LogMessage
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
		
		$file = Join-Path $ProgramDataPath "data-log.log"
		$directory = Split-Path -Parent $file
		$leaf = Split-Path -Leaf $file
		
		if(-not (Test-Path $directory -PathType Container))
		{
			mkdir $directory | Out-Null
		}

		$lines = [System.Collections.Generic.List[string]]::new()
		$all = $null
		# Truncate log file
		if(Test-Path $file -PathType Leaf) 
		{
			if((Get-ItemProperty $file).Length -gt $MaxLogfileSize) 
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
				Remove-Item $file | Out-Null
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
		Write-Output "$($FunctionName): $($_.CategoryInfo.Reason); $($_.Exception.Message)"
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

	$Function = $MyInvocation.MyCommand.Name
	$Data = $null

	try 
	{
		$PipeMessageSeparator = "#"
		$messages = $PipeData -Split $PipeMessageSeparator
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

	$Function = $MyInvocation.MyCommand.Name

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

Function Undo-EventSubscription 
{
	[CmdletBinding()]
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$SourceIdentifier
	)

	$Function = $MyInvocation.MyCommand.Name

	try 
	{
		$subs = Get-EventSubscriber
		foreach($sub in $subs)
		{
			if($sub.SourceIdentifier -eq $SourceIdentifier)
			{
				Unregister-Event -SourceIdentifier $sub.SourceIdentifier | Out-Null
			}
		}
	} 
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

} # Undo-EventSubscription

# <summary> 
#	Handles the 'Command.Interpreted' event and raises the 'Command.Executed' event to 
#	mark completion.
# </summary
# <details> 
#	The completion event is fired despite errors. It should be pointed out, though,
#   by adding a System.Exception object to the event arguments. 
# </details>
Function Use-CommandFromFrontend 
{
	[CmdletBinding()]
	param()

	$Function = $MyInvocation.MyCommand.Name
	$SourceIdentifier = "Command.Interpreted"

	# Remove events
	Undo-EventSubscription -SourceIdentifier $SourceIdentifier | Out-Null

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
			Write-Log -LogType 'Verbose' -LogMessage $message

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
} # Use-CommandFromFrontend 

# <summary> Confirms to frontend execution of command </summary> 
# <details> 
#	Care must be taken to solve any race condition on the pipe since 
#   another write may be happening concurrently as a part of a possible 
#   other queued 'Command.Executed' event subscription. Feedback data 
#   field is formatted as follows: 'command#category#source#date'
# </details>
Function Confirm-CommandExecutionToFrontend 
{
	[CmdletBinding()]
	param()

	$Function = $MyInvocation.MyCommand.Name
	$SourceIdentifier = "Command.Executed"

	# Remove events
	Undo-EventSubscription -SourceIdentifier $SourceIdentifier | Out-Null

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

			Write-Log -LogType 'Verbose' -LogMessage "Waiting for incoming connection ... "
						
			# Check connection
			try 
			{
				if(-not $Pipe.IsConnected)
				{
					$Pipe.WaitForConnection() | Out-Null
				}
			}
			catch 
			{
				Write-Log -Function "$Function#WaitForConnection" -Exception $_
			}

			$JName = "PipeAsyncWrite"
			$x = Start-Job -Name $JName -ArgumentList $Pipe -ScriptBlock {
				$ServerPipe = Args[0]
				if($ServerPipe -eq $null) 
				{
					return
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
				WriteTo-ClientPipeStream -ServerPipe $ServerPipe -Feedback $Feedback | Out-Null
			}

			if($x) 
			{
				$PipeWriteJobs.Add($x)
			}
		}
		catch
		{
			Write-Log -Function $Function -Exception $_
		}
	}

} # Confirm-CommandExecutionToFrontend 

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

	$Function = $MyInvocation.MyCommand.Name

	try 
	{
		if(-not $ServerPipe.CanWrite)
		{
			throw "Server pipe does not have write capability"
		}

		if($ServerPipe.IsConnected)
		{
			Write-Log -LogType 'Verbose' -LogMessage "OK" -NoNewLine 
			Write-Log -LogType 'Verbose' -LogMessage "Attempting write ... "
					    
			# Write data 
			$Encoding = [System.Text.Encoding]::UTF8 
			$Buffer = $Encoding.GetBytes($Feedback) 
			$N = $PipeServer.Write($Buffer, 0, 1)
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
		[System.IO.Pipes.NamedPipeServerStream]$ServerPipe,
		[parameter(Mandatory=$false)]
        [System.Management.Automation.Job]$ReadJob
	) 

	$Function = $MyInvocation.MyCommand.Name
	$Job = $null

	try 
	{
		if($ReadJob)
		{
			$verbose = [System.String]::Empty 
			foreach($v in $ReadJob.Verbose) 
			{
				$verbose += $v
			}
			if(-not [System.String]::IsNullOrEmpty($verbose)) 
			{
				Write-Log -LogType 'Verbose' -LogMessage $verbose
			}

			$StateCompleted = "Completed"
			if($ReadJob.State.ToString() -Match "\A$StateCompleted\Z")
			{
				$data = $ReadJob.Output[-1]
				if(-not [System.String]::IsNullOrEmpty($data))
				{
					$EventArgs = Interprete-PipeData -PipeData $data
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
			else 
			{
				Write-Log -LogType 'Verbose' -LogMessage "Job: $($ReadJob.State); BDate: $($ReadJob.PSBeginTime)"
				Clean-Job -JobName $ReadJob.Name | Out-Null
			}
		}
	
		if($ServerPipe -eq $null) 
		{
			throw "Pipe object is null"
		}

		if(-not $ServerPipe.CanRead)
		{
			throw "Server pipe does not have read capability"
		}

		if($ServerPipe.IsConnected) 
		{
			Write-Log -LogType 'Verbose' -LogMessage "OK" -NoNewLine
					    
			# Read data
			$JName = "PipeReadJob"
			$Job = Start-Job -Name $JName -ArgumentList $ServerPipe -ScriptBlock {
				$data = [System.String]::Empty

				try 
				{
					$Pipe = $Args[0]
					$BufferSize = 1024
					$Buffer = [byte[]]::new($BufferSize)
					$Encoding = [System.Text.Encoding]::UTF8

					Write-Verbose "Attempting read ... "

					$N = $Pipe.Read($Buffer, 0, 1)

					$data = $Encoding.GetString($Buffer) 

					Write-Verbose "OK"
				} 
				catch 
				{
					Write-Log -Function "PipeReadJob" -Exception $_
				}

				return $data
			}
		}
		else 
		{
			Write-Log -LogType 'Verbose' -LogMessage "Disconnected" -NoNewLine
		}
		
	}
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

	return $Job

} # ReadFrom-ClientPipeStream

Function Clean-Job 
{
	[CmdletBinding()]
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$JobName
	)

	$Function = $MyInvocation.MyCommand.Name

	try 
	{
		$job = Get-Job | Where {$_.Name -Match "\A$JobName\Z"}
		if($job)
		{
			Stop-Job -Job $job | Out-Null 
			Remove-Job -Job $job | Out-Null
		}
	} 
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

} # Clean-Job 

Function Maintain-PipeWriteJobs 
{
	[CmdletBinding()]
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[System.Collections.Generic.List[System.Object]]$WriteJobs
	)

	$Function = $MyInvocation.MyCommand.Name

	try 
	{
		
		if($PipeWriteJobs.Count -gt 0) 
		{
			$CleanedJobs = $null
			foreach($job in $PipeWriteJobs) 
			{
				try 
				{
					$JobCompletedState = "Completed"
					$PipeWriteTimeout = 3000
					$start = $job.PSBeginTime 
					$ExecutionTime = (Get-Date).subtract($start).TotalMilliseconds 
					if(
						($ExecutionTime -gt $PipeWriteTimeout) -OR 
						($job.State.ToString() -Match "\A$JobCompletedState\Z") 
					){
						Clean-Job -JobName $job.Name | Out-Null
						$CleanedJobs = [System.Collections.Generic.List[System.Object]]::new()
						$CleanedJobs.Add($job)
					}
				}
				catch 
				{
					Write-Log -Function "$Function#ExecutionTime" -Exception $_
				}
			}

			if($CleanedJobs) 
			{
				foreach($job in $CleanedJobs) 
				{
					$PipeWriteJobs.Remove($job) | Out-Null
				}
			}
		}
	}
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

} # Maintain-PipeWriteJobs

Function Send-FrontendConfigData 
{
	[CmdletBinding()] 
	param 
	(
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateNotNull()]
		[System.IO.Pipes.NamedPipeServerStream]$ServerPipe
	)

	$Function = $MyInvocation.MyCommand.Name
	$Job = $null

	try 
	{
		if($null -eq $ServerPipe) 
		{
			throw "Pipe parameter is null"
		}

		if($ServerPipe.IsConnected) 
		{
			Write-Log -LogType 'Verbose' -LogMessage "Writing config data to client"
					    
			# Read data
			$JName = "PipeWriteConfigDataJob"
			$ConfigData = $UriDataJson
			$Job = Start-Job -Name $JName -ArgumentList $ServerPipe, $UriDataJson -ScriptBlock {
				try 
				{
					$Pipe = $Args[0]
					$UriData = "Configuration#{0}" -f $Args[1]
					$Encoding = [System.Text.Encoding]::UTF8
					$Buffer = $Encoding.GetBytes($UriData)

					Write-Verbose "Attempting write ... "

					$N = $Pipe.Write($Buffer, 0, 1)

					Write-Verbose "OK"
				} 
				catch 
				{
					Write-Log -Function "PipeWriteConfigDataJob" -Exception $_
				}
			}
		}
	}
	catch 
	{
		Write-Log -Function $Function -Exception $_
	}

	return $Job

} # Send-FrontendConfigData

# <summary> Interpretes and responds to a command from a frontend UI </summary>
# <details>
#	Can run as a background job, unless there are unwanted side effects. Provide 
#   for Inversion of Control (IoC) mechanism by firing a "Command.Interpreted" 
#   custom event. Wrap the needed data in the event arguments. 
# </details>
Function Get-CommandFromFrontend 
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$PipeName="ItemsPoolNavigationCommandPipe",
		[bool]$BackgroundJob=$false
	)

	$Function = $MyInvocation.MyCommand.Name

	try 
	{
		$ServerPipeName = $PipeName
		$InterpretedEventSrcId = "Command.Interpreted"
		$ExecutedEventSrcId = "Command.Executed"
		$JobName = "Interprete-Command"
	
		# Clean up any such-like jobs
		Clean-Job -JobName $JobName | Out-Null
	
		$JobScriptBlock = {
			try 
			{
				Write-Log -LogType 'Verbose' -LogMessage "Starting Interpreter script block execution ..."
			    
				$Func = $Args[0]
				$PipeName = $Args[1]
				$PipeDirection = [System.IO.Pipes.PipeDirection]::InOut
				$MaxInstances = 100
				$TransmissionMode = [System.IO.Pipes.PipeTransmissionMode]::Message 
				$PipeOption = [System.IO.Pipes.PipeOptions]::Asynchronous
				$ServerPipe = [System.IO.Pipes.NamedPipeServerStream]::new($PipeName, $PipeDirection, $MaxInstances, $TransmissionMode, $PipeOption)
				
				if($ServerPipe)
				{
					Write-Log -LogType 'Verbose' -LogMessage "Server Pipe created."

					$ReadJob = $null 
					$loop = $true
					$Counter = 0
					do 
					{
						try 
						{
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

							# One-time write config data to client 
							if($Counter -eq 0) 
							{
								$Job = Send-FrontendConfigData -ServerPipe $ServerPipe
							}
							$Counter = 1
							
							# Get command from front-end
							if($ReadJob)
							{
								$ReadJob = $ServerPipe | ReadFrom-ClientPipeStream -ReadJob $ReadJob
							}
							else 
							{
								$ReadJob = $ServerPipe | ReadFrom-ClientPipeStream
							}
						} 
						catch 
						{
							Write-Log -Function "ReadFrom-ClientPipeStream" -Exception $_
						}

						# Give it some time since read is async
						[System.Threading.Tasks.Task]::Delay(3000)
						
						# Clean write jobs
						$PipeWriteJobs | Maintain-PipeWriteJobs
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
			$job = Start-Job -Name $JobName -ArgumentList $Function, $ServerPipeName -ScriptBlock $JobScriptBlock
		}
		else 
		{
			. $JobScriptBlock $Function $ServerPipeName | Out-Null
		}
	}
	catch
	{
		Write-Log -Function $Function -Exception $_
	}

} # Get-CommandFromFrontend

Export-ModuleMember -Function Use-CommandFromFrontend, Confirm-CommandExecutionToFrontend, Get-CommandFromFrontend