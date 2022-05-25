param location string = resourceGroup().location
param envName string = 'env-single-container'

param containerImage string = 'thorstenhans/paint:0.0.1'
param containerPort int = 80

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: 'law-${envName}'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: 'paint'
  params: {
    name: 'paint'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: []
    useExternalIngress: true
    containerPort: containerPort

  }
}

output fqdn string = containerApp.outputs.fqdn
