param name string
param location string = resourceGroup().location

param backendServices array = [
  {
    name: 'cogsvc-playlist-location'
    url: 'https://location.api.cognitive.microsoft.com/openai'
  }
]

var apiManagement = {
  name: 'apim-${name}'
  location: location
  backend: {
    services: map(backendServices, service => {
      id: '/backends/${service.name}'
    })
  }
}

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagement.name
}

resource apimBackends 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = [for service in backendServices: {
  name: service.name
  parent: apim
  properties: {
    type: 'Single'
    protocol: 'http'
    title: service.name
    description: 'Backend for ${service.name}'
    url: service.url
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}]

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
