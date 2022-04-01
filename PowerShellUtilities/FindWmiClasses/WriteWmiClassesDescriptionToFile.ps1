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

	$contents = Get-Content -Path $template

	Write-Host -NoNewLine "Processing template ... "

	if($contents.ToString() -Match "<!--\s*begin\s*-->")
	{
		$begin = $contents.IndexOf($Matches[0])
	}
	if($contents.ToString() -Match "<!--\s*end\s*-->")
	{
		$end = $contents.IndexOf($Matches[0]) + $Matches[0].Length - 1
	}
    
	if($begin -gt 0 -and $end -gt 0) 
	{
		Write-Host -ForegroundColor Green "OK"

		$html = $contents.Substring(0, $begin) + $Payload + $contents.Substring($end, ($contents.Length-$end))
		Out-File -FilePath $FileFullName -Encoding UTF8 -InputObject $html | Out-Null
	}
	else 
	{
		Write-Host -ForegroundColor Red "FAILED"
	}

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
 
# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAn1CdZGHo9KBh6VuuCyJaudB
# QMygggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKeij4z4PDR9nBhcGMU+sGKBFHyi
# MA0GCSqGSIb3DQEBAQUABIIBAMn70EvPYQ+LvbrGM9uMfRxEmmpoMS0q44RGWRn4
# UUW2jMCwWoWg1FAOAxo4An0dVqjl1+q30+BSgzS0nNOY3leCrNnLyBPc24TWhebN
# xq7e62BxEE0llZolPFKhDZ5PtWBH2CdMStIM6A+m42SIYA6F6cMgz680GQyHkC7y
# TC/Js0zJAxLZeC904RdfOqXtoX1j1tQhlvPQCw3M4YaMBc96LKVYr+HwuCWfnrBq
# MYrsDoEfCrLtqrwGHXaN1Q6LRYnATuigdCHNABDp3grWHbFHd9n9/HXRrEd2P8IT
# LOBelLIELfNcA1Ucy6LHp3KqWDjrcuOeNnxZS+RdxcUZW2o=
# SIG # End signature block
