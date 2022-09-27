param location string = resourceGroup().location
param name string = 'grpc'

param containerImage string = 'thorstenhans/grpc-service:0.0.1'
param containerPort int = 5000

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: 'law-${name}'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'aca-env-${name}'
  params: {
    name: 'env-${name}'
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: 'grpc-service'
  params: {
    name: 'grpc-service'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
        {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
        }
    ]
    useExternalIngress: true
  }
}

output fqdn string = containerApp.outputs.fqdn
