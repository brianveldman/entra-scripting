function Enable-ForwardingProfiles {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$TrafficForwardingTypes
    )

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Beta)) {
        Write-Host "Installing Microsoft.Graph.Beta module..." -ForegroundColor Yellow
        Install-Module Microsoft.Graph.Beta -Scope CurrentUser -Force
    }

    if (-not (Get-MgContext)) {
        Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "NetworkAccess.ReadWrite.All"
    }

    $url = "https://graph.microsoft.com/beta/networkAccess/forwardingProfiles"

    try {
        $profiles = Invoke-MgGraphRequest -Uri $url -Method Get

        $matchingProfiles = $profiles.value | Where-Object { $_.trafficForwardingType -in $TrafficForwardingTypes }

        if ($matchingProfiles) {
            foreach ($profile in $matchingProfiles) {
                $ProfileId = $profile.id
                $TrafficType = $profile.trafficForwardingType
                Write-Host "Found Profile for '$TrafficType' with ID: $ProfileId" -ForegroundColor Cyan

                $body = @{
                    state = "enabled"
                } | ConvertTo-Json -Depth 2

                Write-Host "Payload for update: $body" -ForegroundColor Gray

                $updateUrl = "https://graph.microsoft.com/beta/networkAccess/forwardingProfiles/$ProfileId"

                Invoke-MgGraphRequest -Uri $updateUrl -Method Patch -Body $body -ContentType "application/json"

                Write-Host "Forwarding Profile for '$TrafficType' ($ProfileId) updated to state 'enabled' successfully." -ForegroundColor Green
            }
        } else {
            Write-Host "No matching forwarding profiles found for: $($TrafficForwardingTypes -join ', ')." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
