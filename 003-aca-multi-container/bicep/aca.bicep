param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param env array = []
param daprComponents array = []
param secrets array = [
  {
    name: 'docker-password'
    value: containerRegistryPassword
  }
]

@secure()
param containerRegistryPassword string

var registrySecretRefName = 'docker-password'

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      secrets: secrets
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registrySecretRefName
        }
      ]
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
        components: daprComponents
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
