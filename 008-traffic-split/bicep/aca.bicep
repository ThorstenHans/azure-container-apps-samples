// general Azure Container App settings
param location string
param name string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

param revisionMode string
param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name 
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {  

    activeRevisionsMode: revisionMode
      ingress: {
        external: useExternalIngress
        targetPort: containerPort       
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
