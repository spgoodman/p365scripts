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
$FileToReplace = $env:APPDATA + "\Microsoft\Teams\Backgrounds\" + "teamsBackgroundContemporaryOffice01.png"
$FileHash = (Get-FileHash -Path $CustomPNG).Hash
Write-Host -ForegroundColor Green "Setting Teams Custom Background to replace $($FileToReplace)"
Write-Host -ForegroundColor White "Leave this running until you join your meeting with the custom background, then press CTRL-C to exit"
Copy-Item -Path $CustomPNG -Destination $FileToReplace -Force:$True
while (1 -eq 1)
{
    Start-Sleep -Milliseconds 500
    if ((Get-FileHash -Path $FileToReplace -ErrorAction SilentlyContinue).Hash -ne $FileHash)
    {
        Copy-Item -Path $CustomPNG -Destination $FileToReplace -Force:$True
    }
}
