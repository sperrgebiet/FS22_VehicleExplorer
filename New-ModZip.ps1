$srcPath = $PSScriptRoot
$dstPath = $PSScriptRoot
$dstFilename = "FS22_VehicleExplorer.zip"

$tmpPath = Join-Path $env:TMP "TmpZip"

$ignorelist = get-content (Join-Path $srcPath ".gitignore")
$ignorelist += "/New-ModZip.ps1"
$ignorelist += "/textures/png"
$ignoreList += "/screenshots"
$ignoreList += "/README.md"

$ignoreList = ($ignorelist | ?{ -not [string]::IsNullOrEmpty($_) })

if($srcPath.Length -gt 0 -and $dstPath.Length -gt 0)
{
    Remove-Item (Join-Path $dstPath $dstFilename) -Force

    [array]$allFiles = Get-ChildItem -Path $srcPath -Exclude {.gitignore} -Recurse -Attributes !Directory
    [array]$allFolders = Get-ChildItem -Path $srcPath -Exclude {.gitignore} -Recurse -Attributes Directory


    New-Item -ItemType Directory -Path $tmpPath -Force

    foreach($f in $allFolders)
    {
		if( -not $ignorelist.contains($f.FullName.ToString().Replace("$srcPath", "").Replace("\","/")) )
		{
			New-Item -ItemType Directory -Path $f.FullName.ToString().Replace($srcPath, $tmpPath)
		}
    }


    foreach($f in $allFiles)
    {   
        if( -not $ignorelist.contains($f.DirectoryName.ToString().Replace("$srcPath", "").Replace("\","/")) )
        {
            if( -not $ignorelist.contains($f.FullName.ToString().Replace("$srcPath", "").Replace("\","/")) )
            {
                #$F.FullName
                #$f.FullName.ToString().Replace("$srcPath", "").Replace("\","/")
                Copy-Item $f.FullName -Destination $f.FullName.ToString().Replace($srcPath, $tmpPath) -Force
            }
        }
    }

    ##Compress-Archive -Path (Join-Path $tmpPath "\*") -DestinationPath (Join-Path $dstPath $dstFilename)
	# For some reason neither PS nor the .NET libraries create an archive suitable for FS19. the translations folder is included, but not used by the Giants engine
	# Switching to a quick and dirty Winrar solution for now
	$binary = "C:\Program Files\winrar\WinRAR.exe"
    $folder = Join-Path $tmpPath "\*"
    $file = Join-Path $dstPath $dstFilename
	$rarargs = @("a", "-afzip -ep1 -r", "`"$file`"", "`"$($folder)`"" )
	Start-Process -FilePath $binary -ArgumentList $rarargs -Wait

    Remove-Item -Path $tmpPath -Recurse -Force
}