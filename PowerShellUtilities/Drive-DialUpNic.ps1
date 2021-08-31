
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

$ModemDeviceClass = "Modem"
$ModemServiceCommands = New-Object System.Collections.ArrayList
$CommandsCollectionJob = $null
$CommandsExecJob = $null
$ModemService = Get-Service | Where-Object {$_.Name -Match $ModemDeviceClass}

function Make-LogFileName
{
    $ScriptName = & {$myInvocation.ScriptName}
    $segs = $ScriptName.Split(@('/','\'))
    $scriptFileName = $segs[$segs.Count-1]
    $sName = $scriptFileName.Split('.')
    $sName = $sName[0]
    $MyScriptLogFile = Join-Path $home "$($sName).log"

    $MyScriptLogFile
}

function Collect-ModemServiceCommands
{
    param([bool]$AsJob = $true)
    
    $name = "Modem service commands collection"
    $job = Get-Job | Where-Object {$_.Name -Match $name}
    if($job.State -Match "Running")
    {
        Write-Host -NoNewline -ForegroundColor Cyan "JOB [$($job.Name)] is already running. Restarting ... "
        Stop-Job $job.Id
        Remove-Job $job.Id
    }

    $CommandsCollectionJob = Start-Job -Name $name -ScriptBlock {
        $MyLogFile = Make-LogFileName
        $cmd = 0

        while($true)
        {
            if($ModemService)
            {
                while($true)
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
                        Write-Host -NoNewline "]"
                        Write-Host ""
                        
                        $ModemServiceCommands.Add($cmd)
                        if($ModemServiceCommands.Count -EQ 1)
                        {
                            Exec-ModemServiceCommands
                        }
                    }
                    catch
                    {
                        $logLine += "[ERROR]"
                        Write-Host -NoNewline "["
                        Write-Host -NoNewline -ForegroundColor Red "ERROR"
                        Write-Host -NoNewline "]"
                        Write-Host ""
                    }
                    
                    [System.IO.File]::AppendAllText($MyLogFile, $logLine)

                    $cmd += 1
                    #sleep 1
                }
            }
            else
            {
                #Write-Output -ForegroundColor Red "No $($ModemDeviceClass) service found." >> $MyLogFile
                sleep 1
            }
        }
    }

    Write-Host -NoNewline -ForegroundColor Green "[OK]"
    Write-Host " [ID: $($CommandsCollectionJob.Id)]"
}

function Exec-ModemServiceCommands
{
    param([bool]$AsJob = $true)
    $name = "Modem service commands execution"

    $job = Get-Job | Where-Object {$_.Name -Match $name}
    if($job.State -Match "Running")
    {
        Write-Host -NoNewline -ForegroundColor Cyan "JOB [$($job.Name)] is already running. Restarting ... "
        Stop-Job $job.Id
        Remove-Job $job.Id
    }
    
    $CommandsExecJob = Start-Job -Name $name -ScriptBlock {
        $MyLogFile = Make-LogFileName
        $oldLength = 0
    
        while(1)
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

                        [System.IO.File]::AppendAllText($MyLogFile, $logLine)
                        
                        $idx += 1
                        sleep 1
                    }
                }
                $oldLength = $length
            }

            sleep 1
        }
    }

    Write-Host -NoNewline -ForegroundColor Green "[OK]"
    Write-Host " [ID: $($CommandsExecJob.Id)]"
}

function Get-DialUpNicDriverDetails
{
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

    Get-DialUpNicDriverDetails
    Collect-ModemServiceCommands
    Exec-ModemServiceCommands
}

Main