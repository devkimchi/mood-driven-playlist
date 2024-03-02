# Provisions API to Azure API Management for Azure OpenAI
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupLocation = "koreacentral",

    [string]
    [Parameter(Mandatory=$false)]
    $AzureEnvironmentName,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiName,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiDisplayName,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiDescription = '',

    [string]
    [Parameter(Mandatory=$false)]
    $ApiServiceUrl,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiPath,

    [bool]
    [Parameter(Mandatory=$false)]
    $ApiSubscriptionRequired = $true,
    
    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("graphql", "grpc", "http", "odata", "soap", "websocket")]
    $ApiType = "http",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("graphql-link", "grpc", "grpc-link", "odata", "odata-link", "openapi", "openapi+json", "openapi+json-link", "openapi-link", "swagger-json", "swagger-link-json", "wadl-link-json", "wadl-xml", "wsdl", "wsdl-link")]
    $ApiFormat = "openapi-link",

    [string]
    [Parameter(Mandatory=$false)]
    $ApiValue,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions Policies to Azure API Management for Azure OpenAI

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceGroupLocation     <Resource group location>] ``
            [-AzureEnvironmentName      <Azure environment name>] ``
            [-ApiName                   <API name>] ``
            [-ApiDisplayName            <API display name>] ``
            [-ApiDescription            <API description>] ``
            [-ApiServiceUrl             <API service URL>] ``
            [-ApiPath                   <API path>] ``
            [-ApiSubscriptionRequired   <Value indicationg whether to use subscription or not>] ``
            [-ApiType                   <API type>] ``
            [-ApiFormat                 <API format type>] ``
            [-ApiValue                  <API content in either YAML or JSON format>] ``

            [-Help]

    Options:
        -ResourceGroupLocation      Resource group name.
                                    Default value is `'koreacentral`'
        -AzureEnvironmentName       Azure environment name.
        -ApiName                    API name.
        -ApiDisplayName             API display name>
        -ApiDescription             API description
        -ApiServiceUrl              API service URL
        -ApiPath                    API path
        -ApiSubscriptionRequired    Value indicationg whether to use subscription or not.
                                    Default value is `'true`'
        -ApiType                    API type.
                                    Either `'graphql'`, `'grpc'`, `'http'`, `'odata'`, `'soap'`, or `'websocket'`.
                                    Default value is `'http'`
        -ApiFormat                  API format type.
                                    Either `'graphql-link'`, `'grpc'`, `'grpc-link'`, `'odata'`, `'odata-link'`, `'openapi'`, `'openapi+json'`, `'openapi+json-link'`, `'openapi-link'`, `'swagger-json'`, `'swagger-link-json'`, `'wadl-link-json'`, `'wadl-xml'`, `'wsdl'`, or `'wsdl-link'`.
                                    Default value is `'openapi-link'`
        -ApiValue                   API content in either YAML or JSON format.

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

if (($ResourceGroupLocation -eq $null) -or `
    ($AzureEnvironmentName -eq $null) -or `
    ($ApiName -eq $null) -or `
    ($ApiDisplayName -eq $null) -or `
    ($ApiServiceUrl -eq $null) -or `
    ($ApiPath -eq $null) -or `
    ($ApiValue -eq $null)) {
    Show-Usage
    Exit 0
}

$resourceGroupName = "rg-$AzureEnvironmentName"
$repositoryRoot = git rev-parse --show-toplevel

# Provision APIM API
az deployment group create `
    -g $resourceGroupName `
    -n "apim-api-$AzureEnvironmentName" `
    --template-file "$($repositoryRoot)/infra/apiManagementApi.bicep" `
    --parameters name=$AzureEnvironmentName `
    --parameters apiName=$ApiName `
    --parameters apiDisplayName=$ApiDisplayName `
    --parameters apiDescription=$ApiDescription `
    --parameters apiServiceUrl=$ApiServiceUrl `
    --parameters apiPath=$ApiPath `
    --parameters apiSubscriptionRequired=$ApiSubscriptionRequired `
    --parameters apiType=$ApiType `
    --parameters apiFormat=$ApiFormat `
    --parameters apiValue=$ApiValue
