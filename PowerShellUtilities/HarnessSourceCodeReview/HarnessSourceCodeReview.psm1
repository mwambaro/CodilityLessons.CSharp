
# Returns (keyword, color) hash
function Get-KeywordBasedConsoleColor
{
    [CmdLetBinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Keyword,
        [HashTable]$ColorHashTable=$null
    )

    $Colors = [System.ConsoleColor]::GetNames([System.ConsoleColor])
    $Rand = New-Object System.Random
    $MaxHashSize = 100

    if($ColorHashTable -EQ $null)
    {
        $ColorHashTable = New-Object System.Collections.HashTable
    }
    else
    {
        if($ColorHashTable.Count -GE $MaxHashSize)
        {
            $ColorHashTable.Clear() | Out-Null
        }
    }

    foreach($kword in $Keyword)
    {
        Write-Host "Keyword: $kword"
        if(-not $ColorHashTable.ContainsKey($kword))
        {
            $Max = $Colors.Count
            $counter = 0
            $break = $false
            while($counter -LT $Max)
            {
                $col = $Colors[$Rand.Next($Max)]
                if(-not $ColorHashTable.ContainsValue($col))
                {
                    $ColorHashTable.Add($kword, $col) | Out-Null
                    $break = $true
                }
                # Remove the used color
                $NewColors = @()
                foreach($color in $Colors)
                {
                    if($color -ne $col)
                    {
                        $NewColors += $color
                    }
                }
                $Colors = $NewColors
                $Max = $Colors.Count
                # End Remove the used color
                $counter++
                if($break)
                {
                    break
                }
            }
        }
    }

    return $ColorHashTable

} # Get-KeywordBasedConsoleColor()

# <Summary> Squezes information from a string of the type returned by Select-String cmdlet. </Summary>
# <param name="SelectedString"> A string of the type got from Select-String cmdlet </param>
# <param name="ColorHashTable"> A hash table moved around for console colors depending on keywords </param>
# <return> a {keyword, consoleColor} hash table </return>
function Squeeze-InfoFromSelectedString
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$SelectedString,
        [HashTable]$ColorHashTable=$null
    )

    $fileURIregex = "(\w\s*:\s*([\\/][^\\/:]+)+)\s*:\s*(\d+)"

    foreach($SlctdString in $selectedString)
    {
        Write-Output "Selected string: $SlctdString"
        if($SlctdString -Match $fileURIregex)
        {
            $file = Split-Path -Leaf $Matches[1]
            $lineNumber = $Matches[3]
            $SlctdString -Match $keyWordRegex | Out-Null
            $keyWord = $Matches[1]

            $ColorHashTable = Get-KeywordBasedConsoleColor -Keyword $keyWord ` 
                                                           -ColorHashTable $ColorHashTable
            $color = $ColorHashTable[$keyWord]
                    
            Write-Host "$file - ${lineNumber}: "
            Write-Host -NoNewline -ForegroundColor $color $keyWord
        }
    }

    return $ColorHashTable

} # Squeeze-InfoFromSelectedString


# <Summary> Searches a directory of source files for a given word or pattern </Summary>
# <param name="KeywordOrPattern"> A word or pattern to search for </param>
# <param name="SourcesFolderPath"> Directories in which to look </param>
# <return> HashTable with matches as keys and console colors as values OR the folder path, on error </return>
function Find-KeywordInSources
{
    [CmdLetBinding()]
    Param(
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('kop')]
        [System.String]$KeywordOrPattern,
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('sfp')]
        [System.String[]]$SourcesFolderPath
    )
    
    try
    {
        if($SourcesFolderPath -EQ $Null)
        {
            throw "'SourcesFolderPath' parameter is null"
        }

        $ReturnValue = $null
        $ColorHashT = $null
        $psScriptOrModuleRegex = "\.ps[1m]1*\Z"
        $searchPattern = "${KeywordOrPattern}"
        $keyWordRegex = "(${KeywordOrPattern}[^\s]+)"

        $All = Get-ChildItem $SourcesFolderPath -Recurse
        if(-not $All)
        {
            return $ColorHashT
        }

        foreach($_ in $All)
        {
            if($_.PSIsContainer)
            {
                continue
                Write-Output "Fix Me. Continue did not work! Quelle horreur!"
            }
            Write-Output "File: ${$_.Name}"
            if($_.Name -Match $psScriptOrModuleRegex) 
            {
                $fullName = $_.FullName
                $AllMatches = Get-Content $fullName | Select-String -AllMatches ` 
                                                                    -Pattern $searchPattern 
                foreach($match in $AllMatches) 
                {
                    $selectedString = $match
                    $ColorHashT = $selectedString | Squeeze-InfoFromSelectedString -ColorHashTable $ColorHashT
                }
            }
        }

        $ReturnValue = $ColorHashT
    }
    catch
    {
        Write-Error $_
    }
    finally
    {
        $ReturnValue = $SourcesFolderPath
    }

    return $ReturnValue

} # Find-KeywordInSources()

Export-ModuleMember -Function *