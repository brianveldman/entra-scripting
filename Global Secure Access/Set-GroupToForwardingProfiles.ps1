function Set-GroupToForwardingProfiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$TrafficForwardingTypes,

        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )

    $AppRoleId = "00000000-0000-0000-0000-000000000000"

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Applications)) {
        Write-Host "Installing Microsoft.Graph.Applications module..." -ForegroundColor Yellow
        Install-Module Microsoft.Graph.Applications -Scope CurrentUser -Force
    }

    if (-not (Get-MgContext)) {
        Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All", "NetworkAccess.ReadWrite.All", "Group.Read.All"
    }

    $profilesUrl = "https://graph.microsoft.com/beta/networkAccess/forwardingProfiles"
    try {
        Write-Host "Retrieving forwarding profiles..." -ForegroundColor Cyan
        $profiles = Invoke-MgGraphRequest -Uri $profilesUrl -Method GET
    }
    catch {
        Write-Error "Error retrieving forwarding profiles: $_"
        return
    }

    $matchingProfiles = $profiles.value | Where-Object { $_.trafficForwardingType -in $TrafficForwardingTypes }
    if (-not $matchingProfiles) {
        Write-Host "No matching forwarding profiles found for: $($TrafficForwardingTypes -join ', ')." -ForegroundColor Yellow
        return
    }

    foreach ($profile in $matchingProfiles) {
        $ProfileId   = $profile.id
        $TrafficType = $profile.trafficForwardingType
        Write-Host "Found Profile for '$TrafficType' with ID: $ProfileId" -ForegroundColor Cyan

        $spId = $profile.servicePrincipal.id
        Write-Host "Using Service Principal ID: $spId" -ForegroundColor Gray

        $body = @{
            appRoleId   = $AppRoleId
            resourceId  = $spId
            principalId = $GroupId
        }

        Write-Host "Assigning Group '$GroupId' to Service Principal '$spId' using AppRoleId '$AppRoleId'" -ForegroundColor Gray

        try {
            New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $spId -BodyParameter $body
            Write-Host "Assigned Group '$GroupId' to forwarding profile '$TrafficType' (Profile ID: $ProfileId) successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Error assigning group to forwarding profile '$ProfileId': $_"
        }
    }
}
