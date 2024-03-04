# Provisions Credential Manager to Azure API Management
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupLocation = "koreacentral",

    [string]
    [Parameter(Mandatory=$false)]
    $AzureEnvironmentName,

    [string]
    [Parameter(Mandatory=$false)]
    $ProviderName,

    [string]
    [Parameter(Mandatory=$false)]
    $ProviderDisplayName,

    [string]
    [Parameter(Mandatory=$false)]
    $ClientId,

    [string]
    [Parameter(Mandatory=$false)]
    $ClientSecret,

    [string]
    [Parameter(Mandatory=$false)]
    $Scopes,

    [string]
    [Parameter(Mandatory=$false)]
    $AuthUrl,

    [string]
    [Parameter(Mandatory=$false)]
    $TokenUrl,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions Credential Manager to Azure API Management

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceGroupLocation <Resource group location>] ``
            [-AzureEnvironmentName  <Azure environment name>] ``
            [-ProviderName          <Auth provider name>] ``
            [-ProviderDisplayName   <Auth provider display name>] ``
            [-ClientId              <Client ID>] ``
            [-ClientSecret          <Client secret>] ``
            [-Scopes                <Auth scopes>] ``
            [-AuthUrl               <Auth URL>] ``
            [-TokenUrl              <Token URL>] ``

            [-Help]

    Options:
        -ResourceGroupLocation  Resource group name. Default value is `'koreacentral`'
        -AzureEnvironmentName   Azure environment name.
        -ProviderName           Auth provider name.
        -ProviderDisplayName    Auth provider display name.
        -ClientId               Client ID.
        -ClientSecret           Client secret.
        -Scopes                 Auth scopes.
        -AuthUrl                Auth URL.
        -TokenUrl               Token URL.

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
    ($ProviderName -eq $null) -or `
    ($ProviderDisplayName -eq $null) -or `
    ($ClientId -eq $null) -or `
    ($ClientSecret -eq $null) -or `
    ($Scopes -eq $null) -or `
    ($AuthUrl -eq $null) -or `
    ($TokenUrl -eq $null)) {
    Show-Usage
    Exit 0
}

$resourceGroupName = "rg-$AzureEnvironmentName"
$repositoryRoot = git rev-parse --show-toplevel

# Provision APIM credential manager
$apimcredentialmanager = az deployment group create `
    -g $resourceGroupName `
    -n "apim-credential-manager-$AzureEnvironmentName" `
    --template-file "$($repositoryRoot)/infra/apiManagementCredentialManager.bicep" `
    --parameters name="$AzureEnvironmentName" `
    --parameters authProviderName="$ProviderName" `
    --parameters authProviderDisplayName="$ProviderDisplayName" `
    --parameters authProviderClientId="$ClientId" `
    --parameters authProviderClientSecret="$ClientSecret" `
    --parameters authProviderScopes="$Scopes" `
    --parameters authProviderAuthUrl="$AuthUrl" `
    --parameters authProviderTokenUrl="$TokenUrl"

Write-Output "API Management credentials for $ProviderDisplayname has been provisioned"
