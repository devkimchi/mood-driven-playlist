param name string
param location string = resourceGroup().location

param apiName string
param apiDisplayName string
param apiDescription string = ''
param apiServiceUrl string
param apiPath string
param apiSubscriptionRequired bool = true
param apiUseDefaultSubscriptionKey bool = true

@allowed([
  'graphql'
  'grpc'
  'http'
  'odata'
  'soap'
  'websocket'
])
param apiType string = 'http'

@allowed([
  'graphql-link'
  'grpc'
  'grpc-link'
  'odata'
  'odata-link'
  'openapi'
  'openapi+json'
  'openapi+json-link'
  'openapi-link'
  'swagger-json'
  'swagger-link-json'
  'wadl-link-json'
  'wadl-xml'
  'wsdl'
  'wsdl-link'
])
param apiFormat string = 'openapi-link'
param apiValue string

var apiManagement = {
  name: 'apim-${name}'
  location: location
  type: apiType
  api: {
    name: apiName
    displayName: apiDisplayName
    description: apiDescription
    serviceUrl: apiServiceUrl
    path: apiPath
    subscriptionRequired: apiSubscriptionRequired
    subscriptionKeyParameterNames: {
      header: apiUseDefaultSubscriptionKey ? 'Ocp-Apim-Subscription-Key' : 'api-key'
      query: apiUseDefaultSubscriptionKey ? 'subscription-key' : 'api-key'
    }
    format: apiFormat
    value: apiValue
  }
  product: {
    name: 'default'
  }
}

// Get APIM
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagement.name
}

// Provision APIM API
resource apimapi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  name: apiManagement.api.name
  parent: apim
  properties: {
    type: apiManagement.type
    displayName: apiManagement.api.displayName
    description: apiManagement.api.description
    serviceUrl: apiManagement.api.serviceUrl
    path: apiManagement.api.path
    subscriptionRequired: apiManagement.api.subscriptionRequired
    subscriptionKeyParameterNames: {
      header: apiManagement.api.subscriptionKeyParameterNames.header
      query: apiManagement.api.subscriptionKeyParameterNames.query
    }
    format: apiManagement.api.format
    value: apiManagement.api.value
  }
}

resource apimproduct 'Microsoft.ApiManagement/service/products@2023-05-01-preview' existing = {
  name: apiManagement.product.name
  parent: apim
}

resource apimproductapi 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  name: apiManagement.api.name
  parent: apimproduct
  dependsOn: [
    apimapi
  ]
}
