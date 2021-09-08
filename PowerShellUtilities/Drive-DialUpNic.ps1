
###############################################################################################
## Drive-DialUpNic.ps1
##      
##  Tasks:
##      1. Assess exported dial up driver capabilities and how to leverage them.
##      2. Focus on generic uses such as send USSD, send message, ping, etc.
##      3. Manage a Fake PUK's database to use to obfuscate nic identity and do 
##         penetration tests by flooding Telecom Companies servers.
##      4. Write vulnerability reports and optimal practical fixtures and security measures.
##
###############################################################################################

param(
    [Parameter(ValueFromPipeline)]
    [string]$FunctionName="",
    [Parameter(ValueFromPipeline)]
    [System.Collections.Hashtable]$ParameterList=@{}
)

$ModemDeviceClass = "Modem"
$IntMax = [Math]::Pow(2, 32) - 1
$CommandsCollectionJob = $null
$CommandsJsonFile = "ModemCommandsJsonFile.json"
$CommandsExecJob = $null
$Sapi = New-Object -Com Sapi.SpVoice
$TimerEvent = $null
$ModemService = Get-Service | Where-Object {$_.Name -Match $ModemDeviceClass}

function Make-LogFileName
{
    Make-FilePathName
}

function Make-FilePathName
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.String]$FileName = ""
    )

    $ScriptName = & {$myInvocation.ScriptName}
    $segs = $ScriptName.Split(@('/','\'))
    $scriptFileName = $segs[$segs.Count-1]
    $sName = $scriptFileName.Split('.')
    $sName = $sName[0]

    if([string]::IsNullOrEmpty($FileName))
    {
        $FileName = "$($sName).log"
    }

    $MyFile = Join-Path $home $FileName

    $MyFile
}

## <brief> Subscribes to timer event raised by [Timers.Timer] .NET object </brief>
## <param name="TimerEventAction"> Action code executed when timer elapses. Defaults to no action. </param>
## <return> The timer object created. </return>
## <example> Subscribe-ToTimerEvent -TimerEventAction {$Sapi.Speak("Timer has elapsed")} </example>
function Subscribe-ToTimerEvent
{
    param([System.Management.Automation.ScriptBlock]$TimerEventAction = {})

    $srcId = "Timer.Elpased"
    $Event = Get-EventSubscriber | Where-Object{$_.SourceIdentifier -Match "^$($srcId)$"}
    if($Event)
    {
        Unregister-Event -SourceIdentifier $srcId
    }
    
    $Timer = New-Object Timers.Timer
    $Timer.Enabled = $false
    $Timer.Autoreset = $false
    $Timer.Interval = 10000

    $objectEventArgs = @{
        InputObject = $Timer
        EventName = 'Elapsed'
        SourceIdentifier = 'Timer.Elapsed'
    }
    Register-ObjectEvent @objectEventArgs -Action $TimerEventAction
  
    $Timer
}

function Collect-ModemServiceCommands
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.Collections.Hashtable]$Parameters = @{}
    )
    $AsJob = $false
    $AsJob = $Parameters['AsJob']
    $ModemServiceCommands = New-Object System.Collections.ArrayList
    $ModemServiceCommandsFile = $CommandsJsonFile | Make-FilePathName

    Write-Host "Commands to be written to [$ModemServiceCommandsFile]."
    
    $name = "Modem service commands collection"
    $job = Get-Job | Where-Object {$_.Name -Match $name}
    if($job)
    {
        if($job.State -Match "Running")
        {
            Write-Host -NoNewline -ForegroundColor Cyan "JOB [$($job.Name)] is already running. Restarting ... "
            Stop-Job $job.Id
            Remove-Job $job.Id
        }
    }

    $jobBlock = {
        $MyLogFile = Make-LogFileName
        $cmd = 0
        
        $jbBreak = $true
        while($jbBreak)
        {
            if($ModemService)
            {
                $svcBreak = $true
                while($svcBreak)
                {
                    $logLine = ""
                    try
                    {
                        $logLine += "Trying command [$cmd] on [$($ModemService.Name)] ... "
                        Write-Host -NoNewline "Trying command ["
                        Write-Host -NoNewline -ForegroundColor Cyan "$cmd"
                        Write-Host -NoNewline "] on ["
                        Write-Host -NoNewline -ForegroundColor Magenta "$($ModemService.Name)"
                        Write-Host -NoNewline "] ... "
                        
                        $ModemService.ExecuteCommand($cmd)

                        $logLine += "[OK]"
                        Write-Host -NoNewline "["
                        Write-Host -NoNewline -ForegroundColor Green "OK"
                        Write-Host -NoNewline "] [Int Max: $IntMax]"
                        Write-Host ""
                        
                        ModemServiceCommands.Add($cmd)
                        $ModemServiceCommandsJson = ModemServiceCommands | ConvertTo-Json -Compress
                        [System.IO.File]::WriteAllText($ModemServiceCommandsFile, $ModemServiceCommandsJson)
                    }
                    catch
                    {
                        $logLine += "[ERROR]"
                        Write-Host -NoNewline "["
                        Write-Host -NoNewline -ForegroundColor Red "ERROR"
                        Write-Host -NoNewline "] [Int Max: $IntMax]"
                        Write-Host ""
                    }
                    
                    #[System.IO.File]::AppendAllText($MyLogFile, $logLine)

                    if($cmd -GT 0 -AND $cmd -EQ $IntMax)
                    {
                        $cmd = -1
                        continue
                    }
                    elseif ($cmd -LT 0 -AND $cmd -EQ (-$IntMax))
                    {
                        $svcBreak = $false
                        $jbBreak = $false
                    }
                    
                    if($svcBreak)
                    { 
                        if($cmd -GE 0) 
                        { $cmd += 1 }
                        else 
                        { $cmd -= 1}
                    }
                    #sleep 1
                }
            }
            else
            {
                #Write-Output -ForegroundColor Red "No $($ModemDeviceClass) service found." >> $MyLogFile
                sleep 1
            }
        }

        $verbose = "Job '$($name)' is finished."
        $TimerEvent = Subscribe-ToTimerEvent -TimerEventAction {
            $Sapi.Speak($verbose)
        }
        if($TimerEvent)
        {
            $TimerEvent.Enabled = $true
            $TimerEvent.Interval = 10000
            $TimerEvent.Autoreset = $true
        }
    }
    
    $CommandsCollectionJob = $null
    if($AsJob)
    {
        Write-Host -NoNewline "Executing code as a background job ... "
        $CommandsCollectionJob = Start-Job -Name $name -ScriptBlock $jobBlock
    }
    else
    {
        Write-Host -NoNewline "Executing code in current console ... "
        . $jobBlock
    }

    Write-Host -NoNewline -ForegroundColor Green "[OK]"
    if($AsJob) { Write-Host " [ID: $($CommandsCollectionJob.Id)]" }
}

function Exec-ModemServiceCommands
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.Collections.Hashtable]$Parameters = @{}
    )
    $AsJob = $false
    $AsJob = $Parameters['AsJob']
    $name = "Modem service commands execution"
    $ModemServiceCommandsFile = $CommandsJsonFile | Make-FilePathName

    $job = Get-Job | Where-Object {$_.Name -Match $name}
    if($job)
    {
        if($job.State -Match "Running")
        {
            Write-Host -NoNewline -ForegroundColor Cyan "JOB [$($job.Name)] is already running. Restarting ... "
            Stop-Job $job.Id
            Remove-Job $job.Id
        }
    }
    
    $jobBlock = {
        $MyLogFile = Make-LogFileName
        $oldLength = 0
        $ModemServiceCommandsJson = [System.IO.File]::ReadAllText($ModemServiceCommandsFile)
        $ModemServiceCommands = $ModemServiceCommandsJson | ConvertFrom-Json
    
        while($true)
        {         
            if($ModemServiceCommands -AND $ModemService)
            {
                $length = $ModemServiceCommands.Count
                if($length -GT 0)
                {
                    $idx = 0
                    if($length -GT $oldLength)
                    {
                        $idx = $oldLength + 1
                    }
                    
                    while($idx -LT $length)
                    {
                        $cmd = $ModemServiceCommands[$idx]
                        
                        $logLine = "Executing command [$cmd] on [$($ModemService.Name)] ... "
                        Write-Host -NoNewline "Executing command ["
                        Write-Host -NoNewline -ForegroundColor Cyan "$cmd"
                        Write-Host -NoNewline "] on ["
                        Write-Host -NoNewline -ForegroundColor Magenta "$($ModemService.Name)"
                        Write-Host -NoNewline "] ... "
                        
                        $ModemService.ExecuteCommand($cmd)
                        
                        $logLine += "[OK]"
                        Write-Host -NoNewline "["
                        Write-Host -NoNewline -ForegroundColor Green "OK"
                        Write-Host -NoNewline "]"
                        Write-Host ""

                        #[System.IO.File]::AppendAllText($MyLogFile, $logLine)
                        
                        $idx += 1
                        sleep 1
                    }
                }
                $oldLength = $length
            }

            sleep 1
        }
    }
    
    $CommandsExecJob = $null
    if($AsJob)
    {
        Write-Host -NoNewline "Executing code as a background job ... "
        $CommandsExecJob = Start-Job -Name $name -ScriptBlock $jobBlock
    }
    else
    {
        Write-Host -NoNewline "Executing code in current console ... "
        . $jobBlock
    }

    Write-Host -NoNewline -ForegroundColor Green "[OK]"
    if($AsJob) { Write-Host " [ID: $($CommandsExecJob.Id)]" }
}

function Get-DialUpNicDriverDetails
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.Collections.Hashtable]$Parameters = @{}
    )

    # Modem devices
    $dev = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceClass -Match $ModemDeviceClass}
    
    $details = @"
        Manufacturer: $($dev.Manufacturer)
        Device name: $($dev.DeviceName)
        Friendly name: $($dev.FriendlyName)
        Driver version: $($dev.DriverVersion)
        Driver provider: $($dev.DriverProviderName)
        Driver date: $($dev.DriverDate.Substring(0,4))-$($dev.DriverDate.Substring(4,2))-$($dev.DriverDate.Substring(6,2))
        Is Signed ?: $($dev.IsSigned)
        Signer: $($dev.Signer)
        Description: $($dev.Description)

"@
    
    $details
}

function Send-USSD
{}

function Send-TextMessage
{}

function Ping-DialUpServer
{}

function Connect-ToInternetThroughDialUpServer
{}

function Generate-FakePUKs
{}

function Play-WithDialUpServerUsingFakePUKs
{}

function Run-MetasploitAttackOnDialUpServer
{}

function Main
{
    $logfile = Make-LogFileName
    if([System.IO.File]::Exists($logfile))
    {
        [System.IO.File]::Delete($logfile)
    }
    
    if($FunctionName -Match "^Get-DialUpNicDriverDetails$")
    {
        $ParameterList | Get-DialUpNicDriverDetails
    }
    elseif($FunctionName -Match "^Collect-ModemServiceCommands$")
    {
        $ParameterList | Collect-ModemServiceCommands 
    }
    elseif($FunctionName -Match "^Exec-ModemServiceCommands$")
    {
        $ParameterList | Exec-ModemServiceCommands
    }
}

Main