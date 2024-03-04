# Provisions Backend services to Azure API Management for Azure OpenAI
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupLocation = "koreacentral",

    [string]
    [Parameter(Mandatory=$false)]
    $AzureEnvironmentName,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions Backend services to Azure API Management for Azure OpenAI

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceGroupLocation <Resource group location>] ``
            [-AzureEnvironmentName  <Azure environment name>] ``

            [-Help]

    Options:
        -ResourceGroupLocation  Resource group name. Default value is `'koreacentral`'
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

if (($ResourceGroupLocation -eq $null) -or ($AzureEnvironmentName -eq $null)) {
    Show-Usage
    Exit 0
}

# Provision resource group
$resourceGroupName = "rg-$AzureEnvironmentName"

$resourceGroupExists = az group exists -n $resourceGroupName
if ($resourceGroupExists -eq $false) {
    $rg = az group create -n $resourceGroupName -l $ResourceGroupLocation
}

# Provision Azure API Management
$apimServiceName = "apim-$AzureEnvironmentName"
$apim = az apim list -g $resourceGroupName --query "[?name == '$apimServiceName']" | ConvertFrom-Json
if ($apim -eq $null) {
    $apim = az apim create `
        -g $resourceGroupName `
        -n $apimServiceName `
        --publisher-name "Dev Kimchi" `
        --publisher-email 'apim@devkimchi.com' `
        --enable-managed-identity `
        --sku-name "Consumption" `
        --sku-capacity 0 `
        --tags azure-env-name=$AzureEnvironmentName
}

$openAIInstances = @()
$openAIs = az resource list -g $resourceGroupName --query "[?type=='Microsoft.CognitiveServices/accounts'].name" | ConvertFrom-Json | Sort-Object
$openAIs | ForEach-Object {
    $index = $openAIs.IndexOf($_)
    $instanceName = $_
    $endpoint = az cognitiveservices account show -g $resourceGroupName -n $instanceName --query "properties.endpoint" -o tsv
    $apiKey = az cognitiveservices account keys list -g $resourceGroupName -n $instanceName --query "key1" -o tsv

    $openAIInstance = @{ name = $instanceName; url = "$($endpoint.TrimEnd('/'))/openai"; apiKey = "{{AOAI_API_KEY_$index}}"; }
    $openAIInstances += $openAIInstance
}

# Provision Backend services
$repositoryRoot = git rev-parse --show-toplevel
$apimbackend = az deployment group create `
    -g $resourceGroupName `
    -n "apim-backend-$AzureEnvironmentName" `
    --template-file "$($repositoryRoot)/infra/apiManagementBackend.bicep" `
    --parameters name="$AzureEnvironmentName" `
    --parameters backendServices="$($openAIInstances | ConvertTo-Json -Compress | ConvertTo-Json)"

Write-Output "API Management backend services have been provisioned for Azure OpenAI"
