@description('The name of the webapp')
param name string

param location string

var tier = 'B1'

var instanceNumber = 1

module webApp 'Modules/webApp.bicep' = {
  name: name
  params: {
    webAppName: name
    location: location
    tier: tier
    instanceNumber: instanceNumber
  }
}

output webAppId string = webApp.outputs.webAppId
