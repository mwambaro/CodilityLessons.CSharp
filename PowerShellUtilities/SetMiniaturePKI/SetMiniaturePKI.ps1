
################################################################################
## SetMiniaturePKI.ps1
################################################################################

# <summary>
#   Looks for the makecert.exe tool in your system volume.
# </summary>
# <returns>
#   The full path to makecert.exe 
# </returns>
$PlatformSpecificMakeCert = {

    $results = Dir (Split-Path $env:WinDir -Parent) -Recurse -ErrorAction SilentlyContinue | ? Name -Match "Makecert\.exe" | % {
        $_.FullName
    }
    if(-not $results)
    {
        return [System.String]::Empty    
    }

    $Architecture = @{
        "0" = "X86";
        "1" = "MIPS";
        "2" = "Alpha";
        "3" = "PowerPC";
        "5" = "ARM";
        "6" = "Itanium";
        "9" = "X64"
    }

    $Path = [System.String]::Empty

    $GlobRegex = "\W*ARM\W*|\W*X86\W*|\W*MIPS\W*|\W*PowerPC\W*|\W*Itanium\W*|\W*Alpha\W*"
    $ProcessorArch = (Get-WmiObject Win32_Processor).Architecture
    foreach($FullPath in $Results)
    {
        Write-Host -NoNewLine "Processing '$FullPath' ... "
        switch($ProcessorArch)
        {
            9 
            {
                Write-Host "OK" -ForegroundColor Green

                if(($FullPath -Match "\W*X64\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            5 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*ARM\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            0 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*X86\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            1 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*MIPS\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            2 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*Alpha\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            6 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*Itanium\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }

            3 
            {
                Write-Host "OK" -ForegroundColor Green
                if(($FullPath -Match "\W*PowerPC\W*") -or (-not ($FullPath -Match $GlobRegex)))
                {
                    $Path = $FullPath
                }
                break
            }
        }

        if(-not [System.String]::IsNullOrEmpty($Path))
        {
            break
        }
    }

    return $Path

} # PlatformSpecificMakeCert

# <summary>
#   Makes both the root certificate and the client certificate. It also copies 
#   both the 'root.pvk' and the 'root.cer' to the current working directory.
# </summary>
# <param name="RootCAName"> The Root Certification Authority name, not mandatory </param>
# <param name="Subject"> The name of the client for whom to make certificate, not mandatory </param>
# <param name="MakeCertCmd"> The path to the makecert.exe executable, not mandatory </param>
# <returns> The made client certificate, if successfully created. Null, otherwise </returns>
$MakeCertificate = {
    param($RootCAName, $Subject, $MakeCertCmd)

    $MakeCert = $MakeCertCmd
    if([System.String]::IsNullOrEmpty($MakeCert))
    {
        if(-not (Get-Command makecert.exe -ErrorAction SilentlyContinue))
        {    
            $MakeCert = & $PlatformSpecificMakeCert
            if([System.String]::IsNullOrEmpty($MakeCert))
            {
                $errorMessage = "Could not find makecert.exe. `n" +        
                                "This tool is available as part of " + 
                                "Visual Studio, or the Windows SDK."    
                throw $errorMessage
            }    
        }
        else 
        {
            $MakeCert = "Makecert.exe"
        }
    }

    $keyPath = Join-Path ([IO.Path]::GetTempPath()) "root.pvk"
    ## Generate the local certification authority
    if([System.String]::IsNullOrEmpty($RootCAName))
    {
        $RootCAName = "PowerShell Local Certificate Root"
    }
    & $Makecert -n "CN=$RootCAName" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv $keyPath root.cer -ss Root -sr localMachine
    ## Use the local certification authority to generate a self-signed
    ## certificate
    if([System.String]::IsNullOrEmpty($Subject))
    {
        $Subject = "PowerShell User"
    }
    & $Makecert -pe -n "CN=$Subject" -ss MY -a sha1 -eku 1.3.6.1.5.5.7.3.3 -iv $keyPath -ic root.cer
    ## Copy both root.pvk and root.cer so you can back them up
    $dest = Get-Location
    Copy-Item $keyPath -Destination 
    Copy-Item "root.cer" -Destination $dest
    ## Retrieve the certificate
    $cert = Get-ChildItem cert:\CurrentUser\My -codesign | Where-Object 
    { 
        $_.Subject -match $Subject 
    }

    return $cert

} # $MakeCertificate

# <summary> Given the subject's name, it displays their stored certificate </summary>
# <param name="Subject"> The name of the client for whom a certificate was made </param>
$DisplayCertificate = {
    param($Subject)

    if([System.String]::IsNullOrEmpty($Subject))
    {
        $Subject = "PowerShell User"
    }

    $certificate = Dir Cert:\CurrentUser\My | ? Subject -Match $Subject
    if($certificate) 
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null
        [System.Security.Cryptography.X509Certificates.X509Certificate2UI]::DisplayCertificate($certificate)
    }

} # DisplayCertificate

# <summary> It backs up the client certificate as a password-protected PFX file </summary>
# <param name="Cert"> The stored certificate </param>
# <param name="Subject"> The name of the client, say, Subject, for whom a certificate was made. </param>
# <param name="Location"> The backup location path </param>
$BackupStaffCertificate = {
    param($Cert, $Subject, $Location)

    $Path = $Location
    if([System.String]::IsNullOrEmpty($Path))
    {
        $Path = Get-Location
    }
    if(-not (Test-Path $Path -PathType Container))
    {
        $Path = Get-Location
    }

    if([System.String]::IsNullOrEmpty($Subject))
    {
        $Subject = "PowerShell User"
    }

    $FullName = Join-Path $Path 'StaffCertificate.pfx'
    $password = Read-Host "Password" -AsSecureString

    $certificate = $Cert
    if(-not $certificate) 
    {
        $certificate = Dir Cert:\CurrentUser\My | ? Subject -Match $Subject
    }
    if($certificate) 
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null
        $Collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $Collection.Add($certificate)
        $Bytes = $Collection.Export(3, $password)

        $FileStream = New-Object System.IO.FileStream($FullName, "Create")
        $FileStream.Write($Bytes, 0, $Bytes.Length)
        $FileStream.Close()
    }

} # BackupStaffCertificate

# <summary> Installs the root certificate in Local Machine so as to serve enterprise-wide </summary>
$InstallEnterpriseWideRootCertificate = {
    param()

    [System.Reflection.Assembly]::LoadWithPartialName("System.Security")
    $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store("root", "LocalMachine")
    $Collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection 
    $FileName = Join-Path (Get-Location) "root.cer"
    $Collection.Import($FileName)
    $Store.Open("ReadWrite")
    $Store.Add($Collection[0])
    $Store.Close()

} # InstallEnterpriseWideRootCertificate