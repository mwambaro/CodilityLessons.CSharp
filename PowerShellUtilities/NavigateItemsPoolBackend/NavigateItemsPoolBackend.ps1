
param
(
	[parameter(Mandatory=$false, ValueFromPipeline=$true)]
	[ValidateNotNullOrEmpty()]
	[System.String]$ServerPipeName,
	[switch]$LoadScript
)

<# Import Module #>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.ps1', '.psm1'
$path = Join-Path $here $sut
Import-Module -Name $path
#>

<# Import Data #>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.ps1', 'Data.ps1'
$path = Join-Path $here $sut
. $path
#>

Function Get-ItemCategoriesAndSources 
{
	[CmdletBinding()]
	param()

	return $ItemCategoriesAndSources 

} # Get-ItemCategoriesAndSources

if(-not $LoadScript.IsPresent)
{
	
	$Data = Get-ItemCategoriesAndSources 
	if($Data) 
	{
		Write-Output "Script data imported"
	}
	else 
	{
		Write-Output "Script data not imported"
	}
	
	Use-CommandFromFrontend | Out-Null
	Confirm-CommandExecutionToFrontend | Out-Null
	$ServerPipeName | Get-CommandFromFrontend -UriDataJson $Data.UriDataJson
}
# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYPtav83KTCOzRZCUVyZSuyc8
# mSKgggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKZ4o/K6dweJfApfUYDuzCNAkYBS
# MA0GCSqGSIb3DQEBAQUABIIBAIq+Y7DLi/+jbVIUO8vas09XG7DljJfWlha0D5yp
# IwtzV0/4CSnF71p1255/1gnrwzx9BLViQMGhl32Gvtn4zf8ddF+E+d83HskMG/NZ
# gE2l9Vb9Kiu7iwRjGrzJVTd4VbKggEMgFeXrZ4fvJtQU780d9rzhlS1Am2qpjVaj
# jDsviFCBbz63EPeBxWJmBMEvPOCWAapNtB7xGhQgvIeP+Lk2ncmd4ghrt7y3MDXl
# dSnuumrmCjVwPD57ROqIsnt5wQoWnR8ixagyRbpFfNj/r+AMKHwwKyOpO8QJNnSE
# CkFyVZNg/Jze7ERbn4XqTII/zKUwWj5BmscWe6SMfjQxxAA=
# SIG # End signature block
