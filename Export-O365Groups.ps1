<#
.SYNOPSIS
  Example script to export Office 365 Groups with Members and Owners to CSV
.DESCRIPTION
  This is an example script from Practical365.com to demonstrate exporting Office 365 Group / Team members and owners to CSV files
.PARAMETER $CSVFilename
  The path the the CSV file
.INPUTS
  None
.OUTPUTS
  CSV File
.NOTES
  Version:        1.0
  Author:         Steve Goodman
  Creation Date:  20190113
  Purpose/Change: Initial version
  
.EXAMPLE
  Export-O365Groups -CSVFilename .\Groups.CSV
#>
param([parameter(Mandatory=$True, HelpMessage='Please enter a filename for the CSV file to export')]$CSVFilename)

Write-Host -ForegroundColor Green "Loading all Office 365 Groups"
$Groups = Get-UnifiedGroup -ResultSize Unlimited

# Process Groups
$GroupsCSV = @()
Write-Host -ForegroundColor Green "Processing Groups"
foreach ($Group in $Groups)
{
    
    # Get  members
    Write-Host -ForegroundColor Yellow -NoNewline "."
    $Members = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited
    $MembersSMTP=@()
    foreach ($Member in $Members)
    {
        $MembersSMTP+=$Member.PrimarySmtpAddress        
    }
    # Get  owners
    $Owners = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Owners -ResultSize Unlimited
    $OwnersSMTP=@()
    foreach ($Owner in $Owners)
    {
            
        $OwnersSMTP+=$Owner.PrimarySmtpAddress
    }
    
    # Create CSV file line
    $GroupsRow =   [pscustomobject]@{
                    GroupSMTPAddress = $Group.PrimarySmtpAddress
                    GroupIdentity = $Group.Identity
                    GroupDisplayName = $Group.DisplayName
                    MembersSMTP = $MembersSMTP -join "`n"
                    OwnersSMTP = $OwnersSMTP -join "`n"
                    }

    # Add to export array
    $GroupsCSV+=$GroupsRow
        
}

# Export to CSV
Write-Host -ForegroundColor Green "`nCreating and exporting CSV file"
$GroupsCSV | Export-Csv -NoTypeInformation -Path $CSVFilename
