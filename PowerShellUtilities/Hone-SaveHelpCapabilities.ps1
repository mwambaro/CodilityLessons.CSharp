##################################################################################
##  Hone-SaveHelpCapabilities.ps1
##      1. Write a task that lists all modules that need help info and serialize 
##         the collection to a file so it can natively be loaded into PS session.
##      2. 
##
##################################################################################

param(
    [Parameter(ValueFromPipeline)]
    [string]$ModulesJsonFile=""
)

if([string]::IsNullOrEmpty($ModulesJsonFile))
{
    $ModulesJsonFile = Join-Path $Home "PSModulesJsonFile.json"
}

function Serialize-ModulesToFile
{
    Write-Host "Serializing PS module names to "
    Write-Host -NoNewline "[$ModulesJsonFile] ... "

    $Modules = New-Object System.Collections.ArrayList
    Get-Module -All -ListAvailable | ForEach-Object {
        if(-NOT $Modules.Contains($_.Name))
        {
            $Modules.Add($_.Name)
        }
    }
    $ModulesJson = $Modules | Sort-Object | ConvertTo-Json -Compress

    [System.IO.File]::WriteAllText($ModulesJsonFile, $ModulesJson)

    Write-Host -NoNewline -ForegroundColor Green "OK"
    Write-Host -NoNewline " ["
    Write-Host -NoNewline -ForegroundColor Magenta "$($Modules.Count) modules"
    Write-Host -NoNewline "]"

    $ModulesJsonFile
}

$fileName = Serialize-ModulesToFile