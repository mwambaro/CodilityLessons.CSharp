$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Serialize-PSModuleInfoObjects"
{
    $Pathname = Join-Path $Home $SerializationFileName
    $ExistingModules = @("WindowsUpdate", "Azure")

    Context "No command line arguments given"
    {
        It "should return a default path name that exists"
        {
            Serialize-PSModuleInfoObjects | Should be $Pathname
            [System.IO.File]::Exists($Pathname) | Should be $true
        }

        It "should successfully serialize the PS module info object"
        {
            $deserialized = Import-CliXml $Pathname
            $type = $(Get-Module -Name $ExistingModules -ListAvailable)[0].GetType().ToString()
            $deserialized.GetType().ToString() | Should be $type
        }
    }

    Context "File full path name given as argument"
    {
        It "should return a path name given in pipeline that exists"
        {
            $Pathname | Serialize-PSModuleInfoObjects | Should be $Pathname
            [System.IO.File]::Exists($Pathname) | Should be $true
        }

        It "should return a path name given in argument that exists"
        {
            Serialize-PSModuleInfoObjects -FullPathName $Pathname | Should be $Pathname
            [System.IO.File]::Exists($Pathname) | Should be $true
        }

        It "should successfully serialize the PS module info object to the given path name"
        {
            $deserialized = Import-CliXml $Pathname
            $type = $(Get-Module -Name $ExistingModules -ListAvailable)[0].GetType().ToString()
            $deserialized.GetType().ToString() | Should be $type
        }
    }
}
# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSJyaZmLWqMeVa5gPDyAtOUoo
# I1GgggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKEiToo0e2VoIiBLcuwV2rDkJK2q
# MA0GCSqGSIb3DQEBAQUABIIBAEYF8HKGsBqZ7qS3+dSmVud/U5dTA2cIM97W/I5p
# UrtEk9d+Y4HxlRRN0JJ3/E/2jPeYdsToEAODBhnXkV6jUI+QVTS/diVbv705KAtE
# O7W2/k0+rvFniMAfdjzm4tJGD+310mwZbfC6i8nfAwre2OtWVUlIRfkSMgid5IyD
# A1Tg+mU1NEAeRVG5yosVxLddFDwNsGhbd7ioQqN+GQbyWxP5gFNjKOPTqueb2Rnd
# BGZQoyqYGJlDjWBr8WwRw18BAf16BDPo2VbQUklTkVN5YTHsF/Dj2CJNWUP3i1jm
# hDEZ2eouf9Ek9fjRSIEn0ssyh/ejqkmKLcAK24mKCBM8Ym0=
# SIG # End signature block
