# @file: FetchWmiClassesDescription.ps1
# @author: Obed-Edom Nkezabahizi 
# @email: onkezabahizi@gmail.com 

# <summary>
#	Reads an HTML template and processes it into the final HTML file. The template must be named 
#   'Html_template.html' and the information will be filled between the strings '<!-- BEGIN -->' 
#   and '<!-- END -->'. The final HTML file will be named 'Html_file.html'.
# </summary>
# <param name="Payload">
#	The HTML data that will be fed to the HTML template.
# </param>
# <param name="ScriptDir">
#	The working directory for this script. You may ignore it since it can be
#   squeezed from the script runtime using: '& {$MyInvocation.ScriptName}' PS code
# </param>
$ProcessTemplateIntoHtmlFile = {
	param($Payload, $ScriptDir)

	if([System.String]::IsNullOrEmpty($ScriptDir))
	{
		$ScriptName = & {$MyInvocation.ScriptName}
		$ScriptDir = Split-Path -Parent $ScriptName
	}

	Write-Output "PWD: $ScriptDir"

	$template = Join-Path $ScriptDir "Html_template.html"
	$FileFullName = Join-Path $ScriptDir "Html_file.html"

	$contents = Get-Content -Path $template -Encoding String

	Write-Output $contents

	if($contents -Match "<!--\s*begin\s*-->")
	{
		$begin = $contents.IndexOf($Matches[0])
	}
	if($contents -Match "<!--\s*end\s*-->")
	{
		$end = $contents.IndexOf($Matches[0]) + $Matches[0].Length - 1
	}

	$html = $contents.Substring(0, $begin) + $Payload + $contents.Substring($end, ($contents.Length-$end))
	Out-File -FilePath $FileFullName -Encoding UTF8 -InputObject $html | Out-Null

} # ProcessTemplateIntoHtmlFile


# <summary>
#	It generates unique HTML id strings for groups of WMI classes starting 
#   with the same alphabet letter.
# </summary>
# <param name="ClassName">
#	The WMI class name. Generally one of the sorted WMI classes.
# </param>
# <param name="ScriptClassName">
#	Initialize the parameter as follows: [ref]$ScriptClassName = [System.String]::Empty
# </param>
# <param name="ScriptCounter">
#	Initialize the parameter as follows: [ref]$ScriptCounter = 1
# </param>
$WmiClassesIds = {
	param($ClassName, [Ref]$ScriptClassName, [Ref]$ScriptCounter)

	if([System.String]::IsNullOrEmpty($ScriptClassName.Value))
	{
		$ScriptClassName.Value = $ClassName
		$ScriptCounter.Value = 1
		return "WmiClasses-$(($ScriptClassName.Value)[0].ToString())"
	}

	if(($ScriptClassName.Value)[0] -eq $ClassName[0])
	{
		$id = "WmiClasses-$(($ScriptClassName.Value)[0].ToString())$($ScriptCounter.Value)"
		$ScriptCounter.Value = $ScriptCounter.Value + 1
		return $id
	}
	else 
	{
		$ScriptClassName.Value = $ClassName
		$ScriptCounter.Value = 1
		return "WmiClasses-$(($ScriptClassName.Value)[0].ToString())"
	}

} # WmiClassesIds

# <summary>
#	It fetches documentation from WMI classes.	
# <summary>
# <param name="WmiClasses">
#	A collection of WMI classes strings. Each must be formatted as follows:
#		'WmiClassName' + '#' + 'WmiClassNamespace'.
# </param>
# <returns> HTML formatted WMI classes documentation. </returns>
$FetchWmiClassesDescription = {
	param($WmiClasses)

	$information = [System.String]::Empty
	[ref]$ScriptClassName = [System.String]::Empty
	[ref]$ScriptCounter = 1

	$WmiClasses | Sort | % {
		$parts = $_.ToString() -Split "#"
		$name = $parts[0].Trim()
		$Namespace = $parts[1].Trim()
		if(-not ($name -Match "\A__")) 
		{
			try 
			{
				$class = [WmiClass]$name
				$class.PsBase.Options.UseAmendedQualifiers = $true
				
				# class
				$information = $class.PsBase.Qualifiers["Description"].Value 
				if([System.String]::IsNullOrEmpty($information))
				{
					$information = [System.String]::Empty 
				}
				else 
				{
					$id = & $WmiClassesIds $name $ScriptClassName $ScriptCounter
					$information = "<p><a href=`"#nav`">Back to Top</a></p>`n" + 
					               "<h2 id=`"$($id)`"><span>[$Namespace]</span> $name </h2>`n" +
								   "<ol>`n`t" + 
								   "<li style=`"list-style: none`">`n`t" +
								   "$information" +
								   "</li>`n`t" +
								   "<li style=`"list-style: none`">`n`t" + 
								   "<b> Properties: </b>`n`t" + 
								   "</li>`n`t"
				}
				# Properties
				$counter = 0
				($class.PsBase.Properties).Name | Sort | % {
					$property = $_
					$value = $class.PsBase.Properties[$property].Qualifiers["Description"].Value
					if(-not [System.String]::IsNullOrEmpty($value))
					{
						$counter += 1
						$information += "<li>`n`t" + 
								        "<b> $($property): </b> $($value)`n`t" + 
								        "</li>`n`t"
					}
				}
				# Methods
				if(-not [System.String]::IsNullOrEmpty($information))
				{
					$information += "<li style=`"list-style: none`">`n`t" + 
								    "<b> Methods: </b>`n`t" + 
								    "</li>`n`t"
				}
				$counter = 0
				($class.PsBase.Methods).Name | Sort | % {
					$method = $_
					$value = $class.PsBase.Methods[$method].Qualifiers["Description"].Value
					if(-not [System.String]::IsNullOrEmpty($value))
					{
						$counter += 1
						$information += "<li>`n`t" + 
								        "<b> $($method): </b> $($value)`n`t" + 
								        "</li>`n"
					}
				}

				if([System.String]::IsNullOrEmpty($information))
				{
					throw "No description found."
				}

				$information += "</ol>`n`n"
			}
			catch 
			{
				Write-Host -NoNewLine "$name"
				Write-Host -ForegroundColor Red " [FAILED]"
			}
		}
	}

	if([System.String]::IsNullOrEmpty($information)) 
	{
		$information += "`n`n<p><a href=`"#nav`">Back to Top</a></p>`n"
	}

	return $information

} # FetchWmiClassesDescription

# List all classes in ROOT namespace
$namespace = "Root"
$WmiClasses = @()
(Get-WmiObject -List -Namespace $namespace -ErrorAction SilentlyContinue).Name | % {
	$name = $_
	$WmiClasses += "$($name)#$($namespace)"
}

# List every namespace under ROOT namespace
(Get-WmiObject -Namespace root __Namespace).Name | % {
    # List all classes in every namespace under ROOT namespace
	$namespace = "Root\$($_)"
	(Get-WmiObject -List -Namespace $namespace -ErrorAction SilentlyContinue).Name | % {
		$name = $_
		$WmiClasses += "$($name)#$($namespace)"
	}
}

# Get the WMI classes description
$data = & $FetchWmiClassesDescription $WmiClasses
$x = & $ProcessTemplateIntoHtmlFile $data

Write-Host -ForegroundColor Yellow ([System.String]::Format(
	"Look for the 'Html_file.html' in the current working directory " +
	"for the generated HTML file that contains the formatted WMI classes description",
	[System.String]::Empty
))
 