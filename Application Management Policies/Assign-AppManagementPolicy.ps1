function Assign-AppManagementPolicy {
    param(
        [Parameter(Mandatory)]
        [string]$ObjectId,

        [Parameter(Mandatory)]
        [string]$PolicyId
    )

    Import-Module Microsoft.Graph.Applications

    if (-not (Get-MgContext)) {
        Write-Host "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration"
    }

    try {
        $params = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/policies/appManagementPolicies/$PolicyId"
        }

        New-MgApplicationAppManagementPolicyByRef -ApplicationId $ObjectId -BodyParameter $params
        Write-Host "Policy assigned to application successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create or assign policy: $_"
    }
