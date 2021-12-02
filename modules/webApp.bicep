// This module deploys an app service and its related app service plan

@description('Name of the webapp')
param webAppName string

@description('Location of the deployment')
param location string

@description('Tier of the App Service Plan')
@allowed([
  'B1'
  'S1'
])
param tier string

@description('Number of instances')
param instanceNumber int

var hostingPlanName = 'AppSvcPlan-${webAppName}'

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: tier
    capacity: instanceNumber
  }
}

resource webApp 'Microsoft.Web/sites@2020-12-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
  }
}

output webAppId string = webApp.id
output hostingPlanId string = hostingPlan.id
