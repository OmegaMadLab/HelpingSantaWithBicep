@description('The name of the webapp')
param name string

param location string

var tier = 'B1'

var instanceNumber = 1

module webApp 'br:acr5288.azurecr.io/modules/webapp:v1.0.0.2' = {
  name: name
  params: {
    webAppName: name
    location: location
    tier: tier
    instanceNumber: instanceNumber
  }
}

output webAppId string = webApp.outputs.webAppId
