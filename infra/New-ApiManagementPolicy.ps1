# Provisions Policy to Azure API Management
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupLocation = "koreacentral",

    [string]
    [Parameter(Mandatory=$false)]
    $AzureEnvironmentName,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiId = "",

    [string]
    [Parameter(Mandatory=$false)]
    $OperationId = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ProductId = "",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("global", "api", "operation", "product")]
    $PolicyLevel = "api",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("xml", "xml-link", "rawxml", "rawxml-link")]
    $PolicyFormat = "xml-link",

    [string]
    [Parameter(Mandatory=$false)]
    $PolicyValue,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions Policy to Azure API Management

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceGroupLocation <Resource group location>] ``
            [-AzureEnvironmentName  <Azure environment name>] ``
            [-ApiId                 <API ID>] ``
            [-OperationId           <Operation ID>] ``
            [-ProductId             <Product ID>] ``
            [-PolicyLevel           <Policy level>] ``
            [-PolicyFormat          <Policy format type>] ``
            [-PolicyValue           <Policy content in XML format>] ``

            [-Help]

    Options:
        -ResourceGroupLocation  Resource group name. Default value is `'koreacentral`'
        -AzureEnvironmentName   Azure environment name.
        -ApiId                  API ID. If `-PolicyLevel` is `'api'` or `'operation'`, this is required.
        -OperationId            Operation ID. If `-PolicyLevel` is `'operation'`, this is required.
        -ProductId              Product ID. If `-PolicyLevel` is `'product'`, this is required.
        -PolicyLevel            Policy level.
                                Either `'global'`, `'api'`, `'operation'`, or `'product'`.
                                Default value is `'api'`
        -PolicyFormat           Policy format type.
                                Either `'xml'`, `'xml-link'`, `'rawxml'`, or `'rawxml-link'`.
                                Default value is `'xml-link'`
        -PolicyValue            Policy content in XML format.
                                If `-PolicyFormat` is `'xml'` or `'rawxml'`, this should be an XML document.
                                If `-PolicyFormat` is `'xml-link'` or `'rawxml-link'`, this should be a URL to the XML document.

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
    ($PolicyLevel -eq "api" -and $ApiId -eq "") -or `
    ($PolicyLevel -eq "operation" -and ($ApiId -eq "" -or $OperationId -eq "")) -or `
    ($PolicyLevel -eq "product" -and $ProductId -eq "") -or `
    ($PolicyValue -eq $null)) {
    Show-Usage
    Exit 0
}

$resourceGroupName = "rg-$AzureEnvironmentName"
$repositoryRoot = git rev-parse --show-toplevel

# Provision APIM policy
$apimpolicy = az deployment group create `
    -g $resourceGroupName `
    -n "apim-policy-$AzureEnvironmentName" `
    --template-file "$($repositoryRoot)/infra/apiManagementPolicy.bicep" `
    --parameters name="$AzureEnvironmentName" `
    --parameters apiId="$ApiId" `
    --parameters operationId="$OperationId" `
    --parameters productId="$ProductId" `
    --parameters policyLevel="$PolicyLevel" `
    --parameters policyFormat="$PolicyFormat" `
    --parameters policyValue="$PolicyValue"

Write-Output "API Management policy to $PolicyLevel has been provisioned"
