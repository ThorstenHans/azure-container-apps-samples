param location string = resourceGroup().location
param name string = 'pull-via-msi'
param identityName string
param acrName string

param containerImage string = 'nginx:alpine'
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

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
    name: identityName

}

module containerApp 'aca.bicep' = {
  name: 'ca-${name}'
  params: {
    name: 'ca-${name}'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    acrName: acrName
    msiResourceId: msi.id
    containerImage: containerImage
    useExternalIngress: true
    containerPort: containerPort

  }
}

output fqdn string = containerApp.outputs.fqdn
