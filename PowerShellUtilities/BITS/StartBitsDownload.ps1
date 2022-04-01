
$DisplayName = "My Bits Jobs"

$StartBitsDownload = {
	param($sourceFile)

	$name = Split-Path $sourceFile -Leaf
	$path = Join-Path (Join-Path $Home 'AppData') 'Local'
	$newPath = Join-Path $path $DisplayName
	if(-not (Test-Path $newPath -PathType Container))
	{
		$item = New-Item -ItemType Directory -Path $path -Name $DisplayName
	}
	if(-not (Test-Path $newPath -PathType Container))
	{
		throw "Failed to create destination directory: $newPath"
	}
	$destination = @()
	$name | % { $destination += Join-Path $newPath $_ }

	Start-BitsTransfer -Source $sourceFile -Destination $destination -DisplayName $DisplayName -Priority High

} # StartBitsDownload

$PauseBitsDownload = {

	$job = Get-BitsTransfer -Name $DisplayName 
	if($job)
	{
		Suspend-BitsTransfer -BitsJob $job
	}

} # PauseBitsDownload

$ResumeBitsDownload = {

	$job = Get-BitsTransfer -Name $DisplayName 
	if($job)
	{
		Resume-BitsTransfer -BitsJob $job
	}	

} # ResumeBitsDownload