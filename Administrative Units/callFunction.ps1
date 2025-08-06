$displayName = "NL Marketing Team"
$description = "Marketing team members in the Netherlands"
$membershipRule = '(user.department -eq "Marketing") and (user.country -eq "Netherlands")'

New-DynamicAdminUnit `
    -DisplayName $displayName `
    -Description $description `
    -MembershipRule $membershipRule `
    -IsMemberManagementRestricted $false
