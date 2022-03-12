

Import-LocalizedData -BindingVariable Localized -FileName CategoriesAndSources.psd1 -ErrorAction SilentlyContinue

# {source: uriAccordingToCategory} data 
$ItemCategoriesAndSources = @{

	Sources = @(
		$Localized.Local,
		$Localized.Youtube,
		$Localized.Vimeo,
		$Localized.Netflix,
		$Localized.OneDrive,
		$Localized.GoogleDrive,
		$Localized.DropBox,
		$Localized.StreamServer
	);

	Categories = @(
		$Localized.Movies,
		$Localized.TvSeries,
		$Localized.MusicVideos,
		$Localized.MusicAudios,
		$Localized.SourceCode,
		$Localized.Readings
	);

	# JSON
	# e.g URL: www.pagesbleues-rims.com
	UriDataJson = @"
	{
		"$($Localized.Local)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.Readings)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [

			],
			"$($Localized.SourceCode)": [
				""
			]
		},

		"$($Localized.OneDrive)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.Readings)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [

			],
			"$($Localized.SourceCode)": [
				""
			]
		},

		"$($Localized.GoogleDrive)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.Readings)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [

			],
			"$($Localized.SourceCode)": [
				""
			]
		},

		"$($Localized.DropBox)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.Readings)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [

			],
			"$($Localized.SourceCode)": [
				""
			]
		},

		"$($Localized.Youtube)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [
				""
			]
		},

		"$($Localized.Netflix)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [
				""
			]
		},

		"$($Localized.Vimeo)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [
				""
			]
		},

		"$($Localized.StreamServer)": {
			"$($Localized.Movies)": [
				""
			],
			"$($Localized.TvSeries)": [
				""
			],
			"$($Localized.MusicVideos)": [
				""
			],
			"$($Localized.MusicAudios)": [
				""
			]
		}

	}
"@;
}
# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkJkxxf3/emsFejYlU8dKqHML
# 7xagggMnMIIDIzCCAg+gAwIBAgIQUvb471+fFaJF8jxZ844o0jAJBgUrDgMCHQUA
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFLBtRL8x7ki9WrfFNmcUX88xlnn
# MA0GCSqGSIb3DQEBAQUABIIBAJ4zTk6vwhDx1xeJKQeAq5OABe/WgKnF0919cQ7v
# +ACJGhJLz1Dpldhw3b2NR4PJMeRaWkz6EjnFTbY/4QbXLjwtu7oSpu5CBHFZkXLW
# BoR55840DQLDjoVGrd5LmyJ60GgST81PZ7RaSS7y0YMl+8QwTxwZ2l1/rCX8j5Kt
# s6Gi8kvUnlM18Cgj11EukO5rxOC9Nj1vUJmmkrimFIuHRsgVt4oqfKrc3v7DqxBC
# A0y5gxaoLhEHeaLvMjygpTiU5Mq8T6lzh+BPuhw7Y+ZTe9AmWaakecQtSbX+3VDZ
# lAXgJXJVrWiqJJuQG4Bqh2Vt4VmAVi5Dj4P0nJXsjSBMqHc=
# SIG # End signature block
