param name string
param location string = resourceGroup().location

var apiManagement = {
  name: 'apim-${name}'
  location: location
  backend: {
    services: [
      {
        id: '/backends/cogsvc-${name}-australiaeast'
      }
      {
        id: '/backends/cogsvc-${name}-canadaeast'
      }
      {
        id: '/backends/cogsvc-${name}-eastus'
      }
      {
        id: '/backends/cogsvc-${name}-francecentral'
      }
      {
        id: '/backends/cogsvc-${name}-swedencentral'
      }
      {
        id: '/backends/cogsvc-${name}-switzerlandnorth'
      }
    ]
  }
}

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagement.name
}

resource apimLoadbalancer 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'loadbalancer'
  parent: apim
  properties: {
    type: 'Pool'
    protocol: 'http'
    title: 'AOAI Loadbalancer'
    description: 'Loadbalancer for AOAI services'
    url: 'http://localhost'
    pool: {
      services: apiManagement.backend.services
    }
  }
}
