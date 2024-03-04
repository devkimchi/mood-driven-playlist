targetScope = 'subscription'

param name string

// The location where the resources should be deployed.
param location string

param apiManagementPublisherName string = 'Dev Kimchi'
param apiManagementPublisherEmail string = 'apim@devkimchi.com'

param authProviderName string
param authProviderDisplayName string
param spotifyClientId string
@secure()
param authProviderClientSecret string
param spotifyScopes string
param spotifyAuthUrl string
param spotifyTokenUrl string

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': name
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}'
  location: location
  tags: tags
}

module apim './provision-ApiManagement.bicep' = {
  name: 'ApiManagement'
  scope: rg
  params: {
    name: name
    location: location
    tags: tags
    apiManagementPublisherName: apiManagementPublisherName
    apiManagementPublisherEmail: apiManagementPublisherEmail
  }
}

var appTypes = [
  'web'
  'api'
]

module appsvcs './provision-appService.bicep' = [for appType in appTypes: {
  name: 'AppService_${appType}'
  scope: rg
  params: {
    name: name
    location: location
    tags: tags
    appType: appType
  }
}]
