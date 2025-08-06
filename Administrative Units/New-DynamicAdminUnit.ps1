function New-DynamicAdminUnit {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$MembershipRule,

        [ValidateSet("On", "Paused")]
        [string]$MembershipRuleProcessingState = "On",

        [ValidateSet("HiddenMembership", "Public")]
        [string]$Visibility = "HiddenMembership",

        [bool]$IsMemberManagementRestricted = $false
    )

    # Ensure the correct Graph module is loaded
    if (-not (Get-Module Microsoft.Graph.Identity.DirectoryManagement)) {
        Import-Module Microsoft.Graph.Identity.DirectoryManagement
    }

    # Ensure connected to Graph
    if (-not (Get-MgContext)) {
        Connect-MgGraph -Scopes "AdministrativeUnit.ReadWrite.All"
    }

    # Prepare request body
    $params = @{
        displayName = $DisplayName
        description = $Description
        membershipType = "Dynamic"
        membershipRule = $MembershipRule
        membershipRuleProcessingState = $MembershipRuleProcessingState
        visibility = $Visibility
        isMemberManagementRestricted = $IsMemberManagementRestricted
    }

    # Create the administrative unit
    $au = New-MgDirectoryAdministrativeUnit -BodyParameter $params
    Write-Output "Created dynamic Administrative Unit: $($au.DisplayName)"
    return $au
}
