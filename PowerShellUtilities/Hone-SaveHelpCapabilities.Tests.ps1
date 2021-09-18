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