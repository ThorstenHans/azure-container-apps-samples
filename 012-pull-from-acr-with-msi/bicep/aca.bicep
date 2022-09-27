// general Azure Container App settings
param location string
param name string
param containerAppEnvironmentId string

param acrName string
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int
param msiResourceId string
param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msiResourceId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {  
      registries: [
        {
            identity: msiResourceId
            server: '${acrName}.azurecr.io'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: '${acrName}.azurecr.io/${containerImage}'
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
