param($CustomPNG,$CustomJPG)
if ((Test-Path -Path $CustomJPG -ErrorAction SilentlyContinue))
{
    $CustomPNG = $env:TEMP + "\tmp_TeamsCustomBackground.png"
    Add-Type -AssemblyName system.drawing
    $imageFormat = “System.Drawing.Imaging.ImageFormat” -as [type]
    $image = [drawing.image]::FromFile((Get-Item -Path $CustomJPG).FullName)
    $image.Save($CustomPNG, $imageFormat::png)
}
if (!(Test-Path -Path $CustomPNG -ErrorAction SilentlyContinue))
{
    throw $CustomPNG + " not found"
}
$FileToReplace = $env:APPDATA + "\Microsoft\Teams\Backgrounds\" + "teamsBackgroundContemporaryOffice03.png"
$FileLength = (Get-Item $FileToReplace).Length
$FileHash = (Get-FileHash $FileToReplace).Hash
$CustomFileHash = (Get-FileHash $CustomPNG).Hash
# Find cached version
$Cache = $env:APPDATA + "\Microsoft\Teams\Cache"
[array]$MatchingCachedItems = Get-ChildItem $Cache | Where {$_.Length -eq $FileLength}
foreach ($MatchingCachedItem in $MatchingCachedItems)
{
    $CacheFileHash = (Get-FileHash $MatchingCachedItem.FullName).Hash
    if ($CacheFileHash -eq $FileHash)
    {
        $CacheFileToReplace = $MatchingCachedItem.FullName
        break;
    }
}

Write-Host -ForegroundColor Green "Setting Teams Custom Background to replace cache item for $($FileToReplace)"
Copy-Item -Path $CustomPNG -Destination $CacheFileToReplace -Force:$True
