function Set-DefaultAppManagementPolicy {
    param (
        [Parameter(Mandatory)]
        [string]$PasswordMaxLifetime,

        [Parameter(Mandatory)]
        [string]$KeyMaxLifetime
    )

    # Import the required modules
    Import-Module Microsoft.Graph.Identity.SignIns

    # Connect to Microsoft Graph if not already connected
    if (-not (Get-MgContext)) {
        Write-Host "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration"
    }

    Write-Host "Updating default app management policy..." -ForegroundColor Cyan

    $body = @{
        isEnabled = $true
        applicationRestrictions = @{
            passwordCredentials = @(
                @{
                    restrictionType = "passwordAddition"
                    maxLifetime = $null
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2019-10-19T10:37:00Z")
                }
                @{
                    restrictionType = "passwordLifetime"
                    maxLifetime = $PasswordMaxLifetime
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2014-10-19T10:37:00Z")
                }
                @{
                    restrictionType = "symmetricKeyAddition"
                    maxLifetime = $null
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2019-10-19T10:37:00Z")
                }
                @{
                    restrictionType = "symmetricKeyLifetime"
                    maxLifetime = $KeyMaxLifetime
                    restrictForAppsCreatedAfterDateTime = [System.DateTime]::Parse("2014-10-19T10:37:00Z")
                }
            ) 
            keyCredentials = @(
                )
        }
    }

    try {
        Update-MgPolicyDefaultAppManagementPolicy -BodyParameter $body
        Write-Host "Default app management policy successfully updated." -ForegroundColor Green
    } catch {
        Write-Error "Failed to update policy: $_"
    }
}
