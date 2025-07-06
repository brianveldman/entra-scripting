function Set-AppManagementPolicy {
    param (
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$PasswordMaxLifetime,

        [Parameter(Mandatory)]
        [string]$KeyMaxLifetime

    )

    Import-Module Microsoft.Graph.Identity.SignIns

    if (-not (Get-MgContext)) {
        Write-Host "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration"
    }

    Write-Host "Creating app-specific management policy..." -ForegroundColor Cyan

    $params = @{
        displayName   = $DisplayName
        description   = $Description
        isEnabled     = $true
        restrictions  = @{
            passwordCredentials = @(
                @{
                    restrictionType                     = "passwordLifetime"
                    state                               = "enabled"
                    maxLifetime                         = $PasswordMaxLifetime
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2014-10-19T10:37:00Z")
                },
                @{
                    restrictionType                     = "symmetricKeyLifetime"
                    state                               = "enabled"
                    maxLifetime                         = $KeyMaxLifetime
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2014-10-19T10:37:00Z")
                }
            )
        }
    }

    try {
        New-MgPolicyAppManagementPolicy -BodyParameter $params
        Write-Host "App-specific management policy created successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating app-specific management policy: $_" -ForegroundColor Red
    }
}
