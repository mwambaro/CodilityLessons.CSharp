<#
	On Windows 10 v1809, right-click on Start Windows Button, and then click On 
	'Device Manager' menu item. 'Microsoft Management Console (MMC)' displays a tree
	of all devices on your system, known and uknown. We have got to write a module that
	queries the system for all the devices on board a system. Please, use C# and 
	PowerShell so that the code can be cross-platform. I.e., avoid high-level 
	platform-specific API's. That way, the code can run on Linux using Mono.
#>

Function Get-SystemLogicalDevices 
{
	[CmdletBinding()]
	param()

	$LogDevCimInstances = Get-CimInstance -ClassName CIM_LogicalDevice -Namespace root/cimv2
	$Devices = $LogDevCimInstances | Select Name, PNPDeviceID, PrimaryBusType, SecondaryBusType, Status

} # Get-SystemLogicalDevices 

Function Watch-SystemLogicalDevices 
{
	[CmdletBinding()]
	param()

	$alarm = New-Object System.Management.EventQuery 
	# WQL
	$alarm.QueryString = [System.String]::Format(
		"Select * From __InstanceOperationEvent " +
		"Within 1 " + 
		"Where TargetInstance isa CIM_LogicalDevice",
		[System.String]::Empty
	)
	# Watcher 
	$watch = New-Object System.Management.ManagementEventWatcher $alarm 

	for(;;) 
	{
		$result = $watch.WaitForNextEvent()
		$data = @{
			Name = $result.TargetInstance.Name 
			Caption = $result.TargetInstance.Caption 
			Description = $result.TargetInstance.Description 
			DeviceID = $result.TargetInstance.DeviceID
		}

		Write-Output $data 
		Write-Host "------"

		Sleep 1
	}

} # Watch-SystemLogicalDevices