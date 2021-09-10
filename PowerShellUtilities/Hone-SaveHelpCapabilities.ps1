##################################################################################
##  Hone-SaveHelpCapabilities.ps1
##      
##      1. Write a task that lists all modules that need help info and serialize 
##         the collection to a file so it can natively be loaded into PS session.
##      2. 
##
##################################################################################

param(
    [Parameter(ValueFromPipeline)]
    [System.String]$PSModuleInfoObjectsSerializationFullPath=""
)

if([string]::IsNullOrEmpty($PSModuleInfoObjectsSerializationFullPath))
{
    $PSModuleInfoObjectsSerializationFullPath = Join-Path $Home "PSModuleInfoObjectsFile.xml"
}

function Serialize-PSModuleInfoObjects
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.String]$FullPathName=""
    )
    if([System.String]::IsNullOrEmpty($FullPathName))
    {
        $FullPathName = $PSModuleInfoObjectsSerializationFullPath
    }

    Write-Host "Serializing PS module info objects to "
    Write-Host -NoNewline "[$FullPathName] ... "
    
    ## Fetch module names
    $Modules = New-Object System.Collections.ArrayList
    Get-Module -All -ListAvailable | ForEach-Object {
        if(-NOT $Modules.Contains($_.Name))
        {
            $Modules.Add($_.Name)
        }
    }
    
    $PSModuleInfo = Get-Module -Name $Modules -All -ListAvailable
    Export-CliXml -Path $FullPathName -InputObject $PSModuleInfo

    Write-Host -NoNewline -ForegroundColor Green "OK"
    Write-Host -NoNewline " ["
    Write-Host -NoNewline -ForegroundColor Magenta "$($Modules.Count) modules"
    Write-Host -NoNewline "]"

    $FullPathName
}

$fileName = Serialize-PSModuleInfoObjects