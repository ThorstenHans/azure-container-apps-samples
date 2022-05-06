param location string = resourceGroup().location
param name string = 'traffic-split'

param containerImage string = 'thorstenhans/gopher:good_morning'
param containerPort int = 80
param revisions array = [ 
    'space'
    'drunk'
    'panic'
    'hero'
    'devil'
 ] 

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
    name: 'aca-env-${name}'
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: 'aca-${name}'
  params: {
    name: 'aca-${name}'
    location: location
    revisionMode: 'multiple'
    revisions: revisions 
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    useExternalIngress: true

  }
}

output fqdn string = containerApp.outputs.fqdn
