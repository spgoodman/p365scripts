param($NewUser,$FolderTree,$AccessRights,$TestMode=$False)
[array]$Folders = Get-PublicFolder -Identity $FolderTree -Recurse -ResultSize Unlimited -ErrorAction SilentlyContinue
if (!$Folders) { throw "Folder $($FolderTree) not found" }
$Recipient = Get-Recipient -Identity $NewUser -ErrorAction SilentlyContinue
if (!$Recipient) {throw "Recipient $($NewUser) not found" }
foreach ($Folder in $Folders)
{
    [array]$ExistingPermissions = Get-PublicFolderClientPermission -Identity $Folder | Where {$_.User -notlike "Default" -and $_.User -notlike "Anonymous"}
    
    if ($TestMode)
    {
            
        if ($ExistingPermissions)
        {
            Write-Host -ForegroundColor Green "Existing permissions found. Would remove the following for the folder $($Folder.Identity.ToString()):"
            foreach ($ExistingPermission in $ExistingPermissions)
            {
                Remove-PublicFolderClientPermission -Identity $ExistingPermission.Identity -User $ExistingPermission.User -AccessRights $ExistingPermission.AccessRights -WhatIf
            }
        }
        Write-Host -ForegroundColor Green "Would add the following $($AccessRights) permission on $($Folder.Identity.ToString())"
        Add-PublicFolderClientPermission -Identity $Folder.Identity -User $NewUser -AccessRights $AccessRights -WhatIf  
    } else {
        if ($ExistingPermissions)
        {
            Write-Host -ForegroundColor Green "Existing permissions found. Removing permissions set on $($Folder.Identity.ToString()):"
            foreach ($ExistingPermission in $ExistingPermissions)
            {
                Remove-PublicFolderClientPermission -Identity $ExistingPermission.Identity -User $ExistingPermission.User -AccessRights $ExistingPermission.AccessRights -Confirm:$False
            }
        }
        Write-Host -ForegroundColor Green "Adding the $($AccessRights) permission on $($Folder.Identity.ToString()) for $($NewUser)"
        Add-PublicFolderClientPermission -Identity $Folder.Identity -User $NewUser -AccessRights $AccessRights            
    }
}