param($Check=$True,$Remove=$False,$TestMode=$False)
[array]$Folders = Get-PublicFolder -Identity "\" -Recurse -ResultSize Unlimited
foreach ($Folder in $Folders)
{
    [array]$FolderPermissions = Get-PublicFolderClientPermission -Identity $Folder.Identity | Where {$_.User -like "NT User:*"}
    if ($FolderPermissions)
    {
        foreach ($FolderPermission in $FolderPermissions)
        {
            Write-Host -NoNewline "Folder "
            Write-Host -NoNewline  -ForegroundColor Green $FolderPermission.Identity
            Write-Host -NoNewline " has "
            Write-Host -NoNewline  -ForegroundColor Green $FolderPermission.AccessRights
            Write-Host -NoNewline " permissions for user "
            Write-Host -NoNewline  -ForegroundColor Green $FolderPermission.User
            if ($Remove)
            {
                if ($TestMode)
                {
                    Write-Host -ForegroundColor Yellow " - Testing Removal"
                    $FolderPermission | Remove-PublicFolderClientPermission -WhatIf
                } else {
                    Write-Host -ForegroundColor Red " - Removing"
                    $FolderPermission | Remove-PublicFolderClientPermission -Confirm:$False
                }
            } else {
                
                Write-Host
            }
        }
    }
}
