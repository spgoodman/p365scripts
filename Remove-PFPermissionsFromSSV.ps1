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
    $SSVLine1=$SSVLine.Replace("this folder ","").Replace(" permission needs to be removed for user ","@")
    $Folder=$SSVLine1.Split("@")[0]
    $SID=$SSVLine1.Split("@")[1]
            
   $test = Get-PublicFolderClientPermission -Identity $Folder| Where {$_.User -like $SID}
   IF(-not ([string]::IsNullOrEmpty($test.Identity) -or [string]::IsNullOrEmpty($test.User.DisplayName))){
	   if ($TestMode){
		   "Testing removing PF permission for $($Folder) for invalid SID $($SID)" | out-file $logfile -Append
			Get-PublicFolderClientPermission -Identity $Folder| Where {$_.User -like $SID} | Remove-PublicFolderClientPermission -WhatIf
		} 
        else {
			Remove-PublicFolderClientPermission -Identity $test.Identity -User $test.User.DisplayName -Confirm:$False
			"Removed Public Folder permission on " + $test.Identity + " of user " + $test.User.DisplayName | out-file $logfile -Append
		}
    }
}
#I had to make these changes on Exchange 2013 to get the script to work with username and with
#Public Folder names that had a space in them
