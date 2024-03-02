param name string
param location string = resourceGroup().location

param apiId string = ''
param operationId string = ''
param productId string = ''

@allowed([
  'global'
  'api'
  'operation'
  'product'
])
param policyLevel string = 'api'
@allowed([
  'xml'
  'rawxml'
  'xml-link'
  'rawxml-link'
])
param policyFormat string = 'xml-link'
param policyValue string

var apiManagement = {
  name: 'apim-${name}'
  location: location
  apiId: apiId
  operationId: operationId
  productId: productId
  policyFormat: policyFormat
  policyValue: policyValue
}

var isGlobalPolicy = policyLevel == 'global'
var isApiPolicy = policyLevel == 'api'
var isApiOperationPolicy = policyLevel == 'operation'
var isProductPolicy = policyLevel == 'product'

// Get APIM
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagement.name
}

// Provision APIM global policy
resource apimpolicy 'Microsoft.ApiManagement/service/policies@2023-05-01-preview' = if (isGlobalPolicy == true) {
  name: 'policy'
  parent: apim
  properties: {
    format: apiManagement.policyFormat
    value: apiManagement.policyValue
  }
}

// Get APIM API
resource apimapi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = if (isApiPolicy == true || isApiOperationPolicy == true) {
  name: apiManagement.apiId == '' ? 'default' : apiManagement.apiId
  parent: apim
}

// Provision APIM API policy
resource apimapipolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = if (isApiPolicy == true ) {
  name: 'policy'
  parent: apimapi
  properties: {
    format: apiManagement.policyFormat
    value: apiManagement.policyValue
  }
}

// Get APIM API operation
resource apimapioperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = if (isApiOperationPolicy == true) {
  name: apiManagement.operationId == '' ? 'fake' : apiManagement.operationId
  parent: apimapi
}
  
// Provision APIM API operation policy
resource apimapioperationpolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = if (isApiOperationPolicy == true) {
  name: 'policy'
  parent: apimapioperation
  properties: {
    format: apiManagement.policyFormat
    value: apiManagement.policyValue
  }
}

// Get APIM API product
resource apimproduct 'Microsoft.ApiManagement/service/products@2023-05-01-preview' existing = if (isProductPolicy == true) {
  name: apiManagement.productId == '' ? 'fake' : apiManagement.productId
  parent: apim
}

// Provision APIM product policy
resource apimoproductpolicy 'Microsoft.ApiManagement/service/products/policies@2023-05-01-preview' = if (isProductPolicy == true) {
  name: 'policy'
  parent: apimproduct
  properties: {
    format: apiManagement.policyFormat
    value: apiManagement.policyValue
  }
}
