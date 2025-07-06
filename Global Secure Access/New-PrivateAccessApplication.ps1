function New-PrivateAccessApplication {
    param (
        [string]$ConnectorGroupName,
        [string]$ApplicationName,
        [string]$DestinationHost,
        [string]$Ports,
        [string]$Protocol,
        [string]$DestinationType = "ipRange"
    )

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Entra)) {
        Write-Host "Installing Microsoft.Graph.Entra module..." -ForegroundColor Yellow
        Install-Module Microsoft.Graph.Entra -Repository PSGallery -Scope CurrentUser -AllowPrerelease -Force
    }
    
    Connect-Entra -Scopes 'NetworkAccessPolicy.ReadWrite.All', 'Application.ReadWrite.All', 'NetworkAccess.ReadWrite.All'

    $connectorGroup = Get-EntraBetaApplicationProxyConnectorGroup -Filter "Name eq '$ConnectorGroupName'"

    if (-not $connectorGroup) {
        Write-Host "Connector Group '$ConnectorGroupName' not found!" -ForegroundColor Red
        return
    }

    $privateAccessApp = New-EntraBetaPrivateAccessApplication -ApplicationName $ApplicationName -ConnectorGroupId $connectorGroup.Id

    if (-not $privateAccessApp) {
        Write-Host "Failed to create Private Access Application!" -ForegroundColor Red
        return
    }
    
    Write-Host "Private Access Application '$ApplicationName' created successfully." -ForegroundColor Green

    $application = Get-EntraBetaPrivateAccessApplication -ApplicationName $ApplicationName

    $params = @{
        ApplicationId = $application.Id
        DestinationHost = $DestinationHost
        Ports = $Ports
        Protocol = $Protocol
        DestinationType = $DestinationType
    }

    $segment = New-EntraBetaPrivateAccessApplicationSegment @params

    if ($segment) {
        Write-Host "Application Segment created successfully:" -ForegroundColor Green
        Write-Output $segment
    } else {
        Write-Host "Failed to create Application Segment!" -ForegroundColor Red
    }
}
