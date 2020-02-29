param($NewUser,$FolderTree,$AccessRights,$TestMode=$False,$KeepDefaultAnon=$True)
[array]$Folders = Get-PublicFolder -Identity $FolderTree -Recurse -ResultSize Unlimited -ErrorAction SilentlyContinue
if (!$Folders) { throw "Folder $($FolderTree) not found" }
$Recipient = Get-Recipient -Identity $NewUser -ErrorAction SilentlyContinue
if (!$Recipient) {throw "Recipient $($NewUser) not found" }
foreach ($Folder in $Folders)
{
    if ($KeepDefaultAnon)
    {
        [array]$ExistingPermissions = Get-PublicFolderClientPermission -Identity $Folder | Where {$_.User -notlike "Default" -and $_.User -notlike "Anonymous"}
    } else {
        [array]$ExistingPermissions = Get-PublicFolderClientPermission -Identity $Folder
    }
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
        $Return = Add-PublicFolderClientPermission -Identity $Folder.Identity -User $NewUser -AccessRights $AccessRights            
    }
}
