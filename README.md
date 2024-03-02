# Mood-driven Playlist

This is a sample app that catches moods and creates a playlist from Spotify based on the mood analysis

## Getting Started

```bash
# PowerShell
$AZURE_ENV_NAME="playlist$(Get-Random -Min 1000 -Max 9999)"
azd init -e $AZURE_ENV_NAME
azd provision

# Load .env
Get-Content -Path "./.azure/$AZURE_ENV_NAME/.env" | ForEach-Object {
    $name, $value = $_.split('=')
    Set-Content env:$name $value
}

# Provision AOAI
./infra/New-OpenAIs.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM Named Values
./infra/New-ApiManagementNamedValues.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM Backends - AOAI
./infra/New-ApiManagementBackends.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM API - AOAI
./infra/New-ApiManagementApi.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiName aoai `
    -ApiDisplayName AOAI `
    -ApiDescription "Azure OpenAI API" `
    -ApiServiceUrl "https://location.api.cognitive.microsoft.com/openai" `
    -ApiPath aoai `
    -ApiSubscriptionRequired $true `
    -ApiType http `
    -ApiFormat "openapi+json-link" `
    -ApiValue "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-02-15-preview/inference.json"

# Provision APIM API - Spotify
./infra/New-ApiManagementApi.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiName spotify `
    -ApiDisplayName SPOTIFY `
    -ApiDescription "Spotify API" `
    -ApiServiceUrl "https://apim-$($AZURE_ENV_NAME).azure-api.net/spotify" `
    -ApiPath spotify `
    -ApiSubscriptionRequired $true `
    -ApiType http `
    -ApiFormat "openapi+json-link" `
    -ApiValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/openapi-spotify.json"

# Provision APIM Policy - AOAI
./infra/New-ApiManagementPolicy.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiId aoai `
    -PolicyLevel api `
    -PolicyFormat "xml-link" `
    -PolicyValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/policy-api-aoai-loadbalancer.xml"

# Provision APIM Policy - Spotify
./infra/New-ApiManagementPolicy.ps1 `
    -ResourceGroupLocation $env:AZ_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiId spotify `
    -OperationId get-access-token `
    -PolicyLevel operation `
    -PolicyFormat "xml-link" `
    -PolicyValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/policy-api-spotify-operation-accesstoken.xml"

# Set up APIM credential manager on Azure Portal

azd deploy
```



https://github.com/Azure-Samples/azure-openai-apim-load-balancing/blob/main/infra/main.bicep

https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-02-15-preview/inference.json