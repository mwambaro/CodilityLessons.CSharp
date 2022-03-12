﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ServeFrom-RemoteCrecon" 
{
    It "is ever ready to serve crecon data" 
    {
        $true | Should Be $false
    }

    It "supports enterprise-standard authentication scheme"
    {
        $true | Should Be $false
    }

    It "has a robust role management system"
    {
        $true | Should Be $false
    }

    It "beacons handshakeably potential crecon data takers"
    {
        $true | Should Be $false
    }

    It "serves a fixed number of crecon data takers"
    {
        $true | Should Be $false
    }
}

# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCfT5r4pTU9jyolnKWD4lo5eF
# v9CgggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFDnAZWin00SqL7+V6tKbdH9CaWov
# MA0GCSqGSIb3DQEBAQUABIIBAFXcMZD8UerXYlv5FgP6PH2swMwKJPx+CO0N1yhX
# 4m3gyZblxgPzSAjD+TpIi0+NCr9On8AYKAgKSU9w3qHQ+DWwrOlVDJkIJSWHyzBR
# 54mXsuy6ZNzM8YSkvikpUEUKg+jwMx5PhH9W51OCBTDzzh3ks45FJLovYk4DiAVq
# 5kXoIqED7TG3AMaIUkPXp/iShOKibTzat9rvRvhwbyONK/sxs6Wx00oCBDCfe3RS
# ko01JYKb0dmnDb/HimSnpVeaRkFwgEgbZcGydzH42EETLXiYIE39NKv7mjKNV+Qy
# +aM1D3QGJD1qRTRj1t9oNWeN/Z1J0U8jR/I9QNBLrXdtx3Q=
# SIG # End signature block
