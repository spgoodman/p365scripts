<#
.SYNOPSIS  
    Create an Edge Dev "app" for Each of your Microsoft Teams Guest Access Teams
    Use at your own risk
    Based on Tom Arbuthnot's Chrome Web App script from https://tomtalks.blog/2017/11/microsoft-teams-guest-access-chrome-web-apps/
    Steve Goodman, Practical 365
.PARAMETER ShortcutName
    Name of the Teams Guest App Name. This will be prefixed by "Teams -", for example "Teams - Contoso"
.PARAMETER TenantID
    ID of the Tenant. Get your Tenant ID by selecting a Channel or Team in the guest Tenant and choosing "Get Link", then pick out the GUID after tenantID= in the URL 
.PARAMETER ProfilePath
    Path to store the Edge profile folder in containing data for this app. This is by default a random GUID stored in the Local App Data within TeamsGuestApps
#>
param(
    [Parameter(Mandatory = $true, HelpMessage = 'Name of the Teams Guest App Name. This will be prefixed by "Teams -", for example "Teams - Contoso"')]
    [String]$ShortcutName,
    [Parameter(Mandatory = $true, HelpMessage = 'ID of the Tenant. Get your Tenant ID by selecting a Channel or Team in the guest Tenant and choosing "Get Link", then pick out the GUID after tenantID= in the URL')]
    [String]$TenantID,
    [Parameter()]
    [String]$ProfilePath="$($env:LOCALAPPDATA)\TeamsGuestApps\$(([guid]::newguid()).guid)"
)
Write-Output "Please Wait, Edge Dev profile and Start Menu shortcut being created"
$EdgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge Dev\Application\msedge.exe"
if (!(Test-Path $EdgePath)) { throw "Edge Dev exe not found at $($EdgePath)"}
# Create profile
# Start Edge mimimised to create a fresh profile
$id = Start-Process -FilePath  "${env:ProgramFiles(x86)}\Microsoft\Edge Dev\Application\msedge.exe" -ArgumentList "--user-data-dir=`"$ProfilePath`" -first-run" -PassThru -WindowStyle Minimized
Start-Sleep -Seconds 5
# Kill Chrome process
Stop-Process $id
# Create Start Menu Shortcut
$Arguments = $null
[string]$Arguments = "--user-data-dir=`"$ProfilePath`" --app=`"https://teams.microsoft.com/_?TenantID=$($TenantID)`""
$ws = New-Object -com WScript.Shell
$Sm = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\"
$Scp = Join-Path -Path $Sm -ChildPath "$ShortcutName.lnk"
$Sc = $ws.CreateShortcut($Scp)
$Sc.TargetPath = $EdgePath
$sc.Arguments = $Arguments
$Sc.Description = $ShortcutName
$Sc.Save()
Write-Host "Start Menu Shortcut $ShortcutName Created."
Write-Host "Launch from the Start menu and sign in using your credentials, then switch to your target tenant on first launch"