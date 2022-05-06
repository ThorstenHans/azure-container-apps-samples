param location string
param name string
param containerAppEnvironmentId string
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

param envVars array = []
param secrets array = []

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {  
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
      secrets: secrets
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
