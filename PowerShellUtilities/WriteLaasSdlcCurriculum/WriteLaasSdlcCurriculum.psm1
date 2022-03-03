<#
	Given LaaS SDLC, currently, at the Design stage, as far as its OS development is
	concerned, its Author, Obed-Edom Nkezabahizi, needs extensive knowledge in OS 
	design and development. Write a PowerShell module that dynamically generates both the 
	curriculum and the weekly timetable.

	A. Curriculum Objective: Bare metal OS development.
	B. Curriculum:
		1. Strengthen knowledge and understanding of C# and/or PowerShell through
		   source code review. Dynamicity is due to the fact that you may be 
		   shuttling between both languages or doing them concurrently. Also you 
		   may be varying the books used to dig deep in the languages. 
		2. Practice through tasks that cross your mind now and then. These tasks 
		   should be of system type and should leverage the targetted development 
		   languages. Maintain a database of all these tasks and books used to fetch 
		   these practical and best practices subjects: 'UEFI Specification', 
		   'Design Patterns', 'System Design and Analysis', 'DBMS: Mastering SQL Server', and 
		   'Build, Containerize, and Deploy Automation'. 
	C. Weekly Time Table:
		1. Fri: 
			08:00-22:00: Day-Off (House work, Music, Trekking, and Field work)
			22:00-07:00: Bedtime
		2. Mon, Tue, Wed, Thu, Sat, and Sun:
			08:00-10:00: C#/PowerShell code review 
			10:00-11:00: Break 
			11:00-12:00: Read off C#/PowerShell depending on 08:00-10:00 subject 
			12:00-13:00: Lunch break 
			13:00-15:00: C# and/or PowerShell system-type tasks development.
			15:00-16:00: Break 
			16:00-18:00: Development Best Practices Subjects (SDLC and/or DBMS). 
			22:00-07:00: Bedtime
	D. This module:
		1. Write an HTML DOC that leverages PowerShell string interpolation. 
		2. Maintain the mapping between PowerShell variables and the interpollation 
		   points. 
		3. Write a script that runs in the background after log-on, interpolates 
		   the HTML DOC into an HTML Time Table, according to the information in A-C,
		   and displays it using a browser.
#>

# <summary>
# 	Displays the system tray notification message box
# </summary>
# <param name="Title"> The title string of the notification message </param>
# <param name="Text"> The body text in the tray notification box </param>
# <returns> The notification Icon object </returns>
Function Show-SystemTrayNotification 
{
	[CmdletBinding()]
	param
	(
		[parameter(ValueFromPipeline=$true, Mandatory=$true)]
		[ValidateNotNullOrEmpty()] 
		[System.String]
		$Title,
		[parameter(ValueFromPipeline=$true, Mandatory=$true)]
		[ValidateNotNullOrEmpty()] 
		[System.String]
		$Text
	)

	$Duration = 10000

	if([System.Reflection.Assembly]::GetAssembly([System.Windows.Forms.Form]))
	{}
	else 
	{
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	}

	$NotifyIcon = [System.Windows.Forms.NotifyIcon]::new()
	$NotifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info 
	$NotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
	$NotifyIcon.BalloonTipTitle = $Title 
	$NotifyIcon.BalloonTipText = $Text
	$NotifyIcon.Visible = $True 
	$NotifyIcon.ShowBalloonTip($Duration)

	# Sleep for $Duration time, then hide Icon 
	[System.Threading.Thread]::Sleep($Duration)
	$NotifyIcon.Visible = $False
	$NotifyIcon.Dispose()

	return $NotifyIcon

} # Show-SystemTrayNotification

Function Get-TimeTableData 
{
	$data = @"
	Friday: 
		08:00-22:00: Day-Off (House work, Music, Trekking, and Field work)
		22:00-07:00: Bedtime
	Monday, Tuesday, Wednesday, Thursday, Saturday, Sunday:
		08:00-10:00: C#/PowerShell code review 
		10:00-11:00: Break 
		11:00-12:00: Read off C#/PowerShell depending on 08:00-10:00 subject 
		12:00-13:00: Lunch break 
		13:00-15:00: C# and/or PowerShell system-type tasks development.
		15:00-16:00: Break 
		16:00-18:00: Development Best Practices Subjects. 
		18:00-22:00: Leisure time
		22:00-07:00: Bedtime
"@

	return $data

} # Get-TimeTableData

Function Show-TimeTable 
{
	[CmdletBinding()]
	param 
	()

	$TimeData = Get-TimeTableData 
	$lines = $TimeData -Split "`n"

	Write-Output "Lines ($($lines.Count)): 1. $($lines[0])"

	$day = [System.String]::Empty 
	$hash = @{}
	for($i=0; $i -lt $lines.Count; $i++) 
	{
		$string = $lines[$i].Trim().TrimEnd(":")

		#Write-Output $string

		if($string -Match "\A\d{2}") 
		{
			if(-not [System.String]::IsNullOrEmpty($day))
			{
				if($hash.ContainsKey($day)) 
				{
					#Write-Host "$($day): $string"
					$hash[$day] += $string
				}
				else 
				{
					$hash.Add($day, @($string))
				}
			}
		}
		else 
		{
			$day = $string
		}
	}

	#Write-Output "$(ConvertTo-Json -InputObject $hash -Depth 10)"

	for(;;)
	{
		$timeslots = @() 
		foreach($d in $hash.Keys)
		{
			$days = $d -Split ","
			for($i=0; $i -lt $days.Count; $i++) 
			{
				$days[$i] = $days[$i].Trim()
			}

			$today = ((Get-Date).ToLongDateString() -Split " ")[0].Trim(",").Trim()
			if($days -Contains $today) 
			{
				$timeslots += $hash[$d] 
				break
			}
		}

		#Write-Output "$(ConvertTo-Json -InputObject $timeslots -Depth 10)"
		$counter = 0
		$regex = "\A(\d{1,2}\s*:\s*\d{1,2}(\s*:\s*\d{1,2})*)\s*-\s*(\d{1,2}\s*:\s*\d{1,2}(\s*:\s*\d{1,2})*)\s*:\s*(.+)"
		foreach($timeslot in $timeslots) 
		{		
			$color = "Green"
			if($counter % 2 -eq 0)
			{
				$color = "Green"
			}
			else 
			{
				$color = "Yellow"
			}
			Write-Host -ForegroundColor $color "Time slot: $timeslot"
			
			$counter += 1 
			$counter = $counter % 100000

			$match = $timeslot.Trim() -Match $regex
			if($match) 
			{
				try 
				{
					$start = [System.DateTime]::Parse($Matches[1])
					$end = [System.DateTime]::Parse($Matches[3])
					$subject = $Matches[5].Trim()
				}
				catch 
				{
					Write-Output "$_"
				}

				Write-Host -ForegroundColor $color "$start - $($end): $subject"

				$now = Get-Date
				if(($start -le $now) -and ($end -gt $now)) 
				{
					$title = $subject
					$text = "$($timeslots[0..2] -Join "`n")" 
					$Icon = Show-SystemTrayNotification -Title $title -Text $text
				}
			}
		}

		Sleep 1800
	}

} # Show-TimeTable

Function Start-Thread 
{
    [CmdletBinding()]
    Param
	(
        [parameter(Mandatory=$true)] 
		[ScriptBlock] $ScriptBlock,
        [parameter(Mandatory=$false)] 
		[ValidateScript({Test-Path $_ -PathType Container})] 
		[String] $StartPath = ".",
        [parameter(Mandatory=$false)] 
		[Hashtable] $Params = @{}
    )

    $ps = [PowerShell]::Create()
    $ps.Runspace = [RunspaceFactory]::CreateRunspace()
    $ps.Runspace.Open()
    $null = $ps.AddScript("Set-Location ""$(Resolve-Path $StartPath)""")
    $null = $ps.AddScript($ExecFunctions) # import into thread context
    $null = $ps.AddScript($ScriptBlock).AddParameters($Params)
    $async = $ps.BeginInvoke()

    return @{Name=$ScriptBlock.Ast.Name; AsyncResult=$async; PowerShell=$ps}

} # Start-Thread()

Function Write-TimeTable 
{
	[CmdletBinding()]
	param()

	Start-Thread ${Function:Show-TimeTable}

} # Run-TimeTable