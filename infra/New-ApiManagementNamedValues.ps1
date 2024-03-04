# Provisions Named Values to Azure API Management for Azure OpenAI
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
    Write-Output "    This provisions Named Values to Azure API Management for Azure OpenAI

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
    $instanceName = $_
    $endpoint = az cognitiveservices account show -g $resourceGroupName -n $instanceName --query "properties.endpoint" -o tsv
    $apiKey = az cognitiveservices account keys list -g $resourceGroupName -n $instanceName --query "key1" -o tsv

    $openAIInstance = @{ Name = $instanceName; Endpoint = $endpoint; ApiKey = $apiKey; }
    $openAIInstances += $openAIInstance
}

# Provision Named Values
$openAIInstances | ForEach-Object {
    $index = $openAIInstances.IndexOf($_)

    # Provision AOAI API key
    $nv = az apim nv create `
        -g $resourceGroupName `
        -n $apimServiceName `
        --named-value-id "AOAI_API_KEY_$index" `
        --display-name "AOAI_API_KEY_$index" `
        --value "$($_.ApiKey)" `
        --secret true

    Write-Output "NamedValue, AOAI_API_KEY_$index, has been provisioned"

    # Provision AOAI instance name
    $nv = az apim nv create `
        -g $resourceGroupName `
        -n $apimServiceName `
        --named-value-id "AOAI_NAME_$index" `
        --display-name "AOAI_NAME_$index" `
        --value "$($_.Name)" `
        --secret false

    Write-Output "NamedValue, AOAI_NAME_$index, has been provisioned"
}
