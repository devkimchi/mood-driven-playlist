# Run post-provision script
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $AzureEnvironmentName,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This runs the post-provision scripts

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-AzureEnvironmentName  <Azure environment name>] ``

            [-Help]

    Options:
        -AzureEnvironmentName   Azure eovironment name.

        -Help:                  Show this message.
"

    Exit 0
}

# Show usage
$needHelp = $Help -eq $true
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

if ($AzureEnvironmentName -eq $null) {
    Show-Usage
    Exit 0
}

$AZURE_ENV_NAME = $AzureEnvironmentName

$repositoryRoot = git rev-parse --show-toplevel

# Load .env
Get-Content -Path "$repositoryRoot/.azure/$AZURE_ENV_NAME/.env" | ForEach-Object {
    $name, $value = $_.split('=')
    Set-Content env:$name $value
}

# Load config.json
$config = Get-Content -Path "$repositoryRoot/.azure/$AZURE_ENV_NAME/config.json" | ConvertFrom-Json
Set-Content env:CREDENTIAL_PROVIDER_NAME $config.infra.parameters.authProviderName
Set-Content env:CREDENTIAL_PROVIDER_DISPLAY_NAME $config.infra.parameters.authProviderDisplayName
Set-Content env:SPOTIFY_CLIENT_ID $config.infra.parameters.spotifyClientId
Set-Content env:SPOTIFY_CLIENT_SECRET $config.infra.parameters.spotifyClientSecret
Set-Content env:SPOTIFY_SCOPES $config.infra.parameters.spotifyScopes
Set-Content env:SPOTIFY_AUTH_URL $config.infra.parameters.spotifyAuthUrl
Set-Content env:SPOTIFY_TOKEN_URL $config.infra.parameters.spotifyTokenUrl

# Provision AOAI
. $repositoryRoot/infra/New-OpenAIs.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM Named Values
. $repositoryRoot/infra/New-ApiManagementNamedValues.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM Backends - AOAI
. $repositoryRoot/infra/New-ApiManagementBackends.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME

# Provision APIM API - Backend
. $repositoryRoot/infra/New-ApiManagementApi.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiName api `
    -ApiDisplayName Backend `
    -ApiDescription "Backend API" `
    -ApiServiceUrl "appsvc-$AZURE_ENV_NAME-api.azurewebsites.net/api" `
    -ApiPath api `
    -ApiSubscriptionRequired $true `
    -ApiUseDefaultSubscriptionKey $true `
    -ApiType http `
    -ApiFormat "openapi+json-link" `
    -ApiValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/openapi-backend.json"

# Provision APIM API - AOAI
. $repositoryRoot/infra/New-ApiManagementApi.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiName openai `
    -ApiDisplayName OpenAI `
    -ApiDescription "Azure OpenAI API" `
    -ApiServiceUrl "https://$($env:AZURE_LOCATION).api.cognitive.microsoft.com/openai" `
    -ApiPath openai `
    -ApiSubscriptionRequired $true `
    -ApiUseDefaultSubscriptionKey $false `
    -ApiType http `
    -ApiFormat "openapi+json-link" `
    -ApiValue "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-02-15-preview/inference.json"

# Provision APIM API - Spotify
. $repositoryRoot/infra/New-ApiManagementApi.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiName spotify `
    -ApiDisplayName Spotify `
    -ApiDescription "Spotify API" `
    -ApiServiceUrl "https://apim-$($AZURE_ENV_NAME).azure-api.net/spotify" `
    -ApiPath spotify `
    -ApiSubscriptionRequired $true `
    -ApiUseDefaultSubscriptionKey $true `
    -ApiType http `
    -ApiFormat "openapi+json-link" `
    -ApiValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/openapi-spotify.json"

# Provision APIM Policy - AOAI
. $repositoryRoot/infra/New-ApiManagementPolicy.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiId openai `
    -PolicyLevel api `
    -PolicyFormat "xml-link" `
    -PolicyValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/policy-api-openai-loadbalancer.xml"

# Provision APIM Policy - Spotify
. $repositoryRoot/infra/New-ApiManagementPolicy.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ApiId spotify `
    -OperationId get-access-token `
    -PolicyLevel operation `
    -PolicyFormat "xml-link" `
    -PolicyValue "https://raw.githubusercontent.com/devkimchi/mood-driven-playlist/main/infra/policy-api-spotify-operation-accesstoken.xml"

# Provision APIM Credential Manager - Spotify
. $repositoryRoot/infra/New-ApiManagementCredentialManager.ps1 `
    -ResourceGroupLocation $env:AZURE_LOCATION `
    -AzureEnvironmentName $AZURE_ENV_NAME `
    -ProviderName $env:CREDENTIAL_PROVIDER_NAME `
    -ProviderDisplayName $env:CREDENTIAL_PROVIDER_DISPLAY_NAME `
    -ClientId $env:SPOTIFY_CLIENT_ID `
    -ClientSecret $env:SPOTIFY_CLIENT_SECRET `
    -Scopes $env:SPOTIFY_SCOPES `
    -AuthUrl $env:SPOTIFY_AUTH_URL `
    -TokenUrl $env:SPOTIFY_TOKEN_URL
