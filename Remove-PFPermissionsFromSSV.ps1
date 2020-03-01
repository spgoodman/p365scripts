param($SSVOutput,$TestMode=$False)
if (!(Test-Path -Path $SSVOutput))
{
    throw "File $($SSVOutput) not found"
}
[array]$SSVContent = Get-Content -Path $SSVOutput | Where {$_ -like "*permission needs to be removed*"}
if (!$SSVContent)
{
    throw "No permissions found to remove"
}
foreach ($SSVLine in $SSVContent)
{
    $SSVLine=$SSVLine.Replace("this folder ","")
    $SSVLine=$SSVLine.Replace("permission needs to be removed for user ","");
    $Folder=($SSVLine.Split(" "))[0]
    $SID="NT $(($SSVLine.Split(" "))[2])"
    if ($TestMode)
    {
        Write-Host -ForegroundColor Green "Testing removing PF permission for $($Folder) for invalid SID $($SID)"
        Get-PublicFolderClientPermission -Identity $Folder| Where {$_.User -like $SID} | Remove-PublicFolderClientPermission -WhatIf
    } else {
         Write-Host -ForegroundColor Green "Forcing removal of PF permission for $($Folder) for invalid SID $($SID)"
        Get-PublicFolderClientPermission -Identity $Folder| Where {$_.User -like $SID} | Remove-PublicFolderClientPermission -Confirm:$False
    }
}