param name string
param location string = resourceGroup().location

param tags object = {}

@allowed([
  'web'
  'api'
  'apim'
])
param appType string = 'web'

var workspace = {
  name: 'wrkspc-${name}-${appType}'
  location: location
  tags: tags
}

resource wrkspc 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspace.name
  location: workspace.location
  tags: workspace.tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output id string = wrkspc.id
output name string = wrkspc.name
