

Import-LocalizedData -BindingVariable Localized -FileName CategoriesAndSources -ErrorAction SilentlyContinue

# {source: uriAccordingToCategory} data

$Sources = @(
	$Localized.Local,
	$Localized.Youtube,
	$Localized.Vimeo,
	$Localized.Netflix,
	$Localized.OneDrive,
	$Localized.GoogleDrive,
	$Localized.DropBox,
	$Localized.StreamServer
)

$Categories = @(
	$Localized.Movies,
	$Localized.TvSeries,
	$Localized.MusicVideos,
	$Localized.MusicAudios,
	$Localized.SourceCode,
	$Localized.Readings
)

# JSON
$UriDataJson = @"
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
		"$($Localized.MusicVideos": [
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
"@