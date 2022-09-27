param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param env array = [] 
param secrets array = [
    {
        name: 'docker-password'
        value: containerRegistryPassword
    }
]

@secure()
param containerRegistryPassword string

var registrySecretRefName = 'docker-password'

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
    name: containerAppName
    location: location
    properties: {
        managedEnvironmentId: environmentId
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
            dapr: {
                enabled: true
                appPort: containerPort
                appId: containerAppName
                appProtocol: 'http'
            }
        }
        template: {
            containers: [
                {
                    image: '${containerRegistry}/${containerImage}'
                    name: containerAppName
                    env: env
                }
            ]
            scale: {
                minReplicas: 1
                maxReplicas: 1
            }
        }
    }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
