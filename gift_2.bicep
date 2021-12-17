@description('The name of the webapp')
param name string

@allowed([
  'PROD'
  'TEST'
])
@description('The environment object of the deployment')
param environment string

var environmentRegion = {
  TEST: [
    'westeurope'
  ]
  PROD: [
    'westeurope'
    'northeurope'
  ]
}

var environmentSettings = {
  TEST: {
      tier: 'B1'
      instanceNumber: 1
  }
  PROD: {
      tier: 'S1'
      instanceNumber: 2
  }
}

module webApp 'br:acr5288.azurecr.io/modules/webapp:v1.0.0.5' = [for region in environmentRegion[environment]: {
  name: 'webApp-${environment}-${region}'
  params: {
    webAppName: name
    location: region
    tier: environmentSettings[environment].tier
    instanceNumber: environmentSettings[environment].instanceNumber
  }
}]

resource trafficManager 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = if (environment == 'PROD' ? bool('true') : bool('false')) {
  name: 'TrafficManager'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Weighted'
    dnsConfig: {
      relativeName: 'TrafficManager${uniqueString(resourceGroup().id)}'
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      toleratedNumberOfFailures: 3
      timeoutInSeconds: 10
    }
    endpoints: [for (region, i) in environmentRegion[environment]: {
      name: '${region}-Endpoint'
      type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
      properties: {
        endpointStatus: 'Enabled'
        endpointMonitorStatus: 'Stopped'
        targetResourceId: webApp[i].outputs.webAppId
        weight: 1
        priority: (i + 1)
        endpointLocation: region
      }
    }]
  }
}

output tfUri string = trafficManager.properties.dnsConfig.fqdn

