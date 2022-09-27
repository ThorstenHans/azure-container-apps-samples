param location string = resourceGroup().location
param name string = 'single-container'

param containerImage string = 'thorstenhans/paint:0.0.1'
param containerPort int = 80

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: 'law-${name}'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: 'env-${name}'
    location: location
    
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: 'paint'
  params: {
    name: 'aca-${name}'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    useExternalIngress: true
    containerPort: containerPort
  }
}

output fqdn string = containerApp.outputs.fqdn
