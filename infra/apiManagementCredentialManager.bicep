param name string
param location string = resourceGroup().location

param authProviderName string
param authProviderDisplayName string
param authProviderClientId string
@secure()
param authProviderClientSecret string
param authProviderScopes string
param authProviderAuthUrl string
param authProviderTokenUrl string

var apiManagement = {
  name: 'apim-${name}'
  location: location
  credentialManager: {
    name: authProviderName
    displayName: authProviderDisplayName
    identityProvider: 'oauth2'
    clientId: authProviderClientId
    clientSecret: authProviderClientSecret
    scopes: authProviderScopes
    authUrl: authProviderAuthUrl
    tokenUrl: authProviderTokenUrl
  }
}

// Get APIM
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagement.name
}

resource apimcredentialmanager 'Microsoft.ApiManagement/service/authorizationProviders@2023-05-01-preview' = {
  name: apiManagement.credentialManager.name
  parent: apim
  properties: {
    displayName: apiManagement.credentialManager.displayName
    identityProvider: apiManagement.credentialManager.identityProvider
    oauth2: {
      redirectUrl: 'https://authorization-manager.consent.azure-apim.net/redirect/apim/${apiManagement.name}'
      grantTypes: {
        authorizationCode: {
          clientId: apiManagement.credentialManager.clientId
          clientSecret: apiManagement.credentialManager.clientSecret
          scopes: apiManagement.credentialManager.scopes
          authorizationUrl: apiManagement.credentialManager.authUrl
          refreshUrl: apiManagement.credentialManager.tokenUrl
          tokenUrl: apiManagement.credentialManager.tokenUrl
        }
      }
    }
  }
}

// resource apimcredentialmanagerauth 'Microsoft.ApiManagement/service/authorizationProviders/authorizations@2023-05-01-preview' = {
//   name: apiManagement.credentialManager.name
//   parent: apimcredentialmanager
//   properties: {
//     authorizationType: 'OAuth2'
//     oauth2grantType: 'AuthorizationCode'
//   }
// }
