$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\..+', ''

#Write-OutPut "Sut: $sut"

$sourceItem = Get-ChildItem -Path $here | Where-Object {$_ -Match "\A$sut\.(psm\d|ps\d)"}
$module = {}
$script = {}

if($sourceItem.Name -Match "\A$sut\.psm\d\Z")
{
	$module = "$here\$($sourceItem.Name)"
}
elseif($sourceItem.Name -Match "\A$sut\.ps\d\Z")
{
	$script = "$here\$($sourceItem.Name)"
	$module = {}
}

Write-Output "Module: $module"
Write-Output "Script: $script"

Import-Module $module -ErrorAction SilentlyContinue
. $script -ErrorAction SilentlyContinue


Describe "Find-KeywordInSources" {
	
	It "should find matches in files" {
		$matches = Find-KeywordInSources -KeywordOrPattern "ValueFromPipelineBy" -SourcesFolderPath @($(Get-Location))
		$matches.GetType().ToString() | Should Be "System.Collections.HashTable"
	}
}

# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFZPpjl54axmyfJI+QU5h4hzB
# M9mgggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFEtvHaC9TiUfEkmRb0nERde+gCpL
# MA0GCSqGSIb3DQEBAQUABIIBAMWMmUu+8Rnbjmo4rPQNYLF6xAhRVKIDX7wDahB/
# Lxl+9tpNKvJXJSKIlBEjhqke7OaYTyIpvCU8BVxi09qOkJ614GW9HdjNDAbXed8D
# WPYG1uR8P5cGORzgpkTKqAsYlkl9Zrt+SE+pLXk5Jpn5aAtz/THZXmQIfOaACkkW
# TEYcdRvHSXZFETM75bBRZpysjjqELsVb1V58ieLv/fqGT8ICP/LpfElKuavkYz96
# EYZpk3cmWnhe4FI64iVygNG68vVuY672iqGHai5CSWwSDaSnV3A0Ubgzkm1Wrbya
# tZfhezPX/BKe3MANcU/5viPQB0uVwOwL3V+1c77Svpu+hKA=
# SIG # End signature block
