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
}
resource wrkspc 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspace.name
}

var appInsights = {
  name: 'appins-${name}-${appType}'
  location: location
  tags: tags
}

resource appins 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights.name
  location: appInsights.location
  kind: 'web'
  tags: appInsights.tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    Request_Source: 'rest'
    WorkspaceResourceId: wrkspc.id
  }
}

output id string = appins.id
output name string = appins.name
