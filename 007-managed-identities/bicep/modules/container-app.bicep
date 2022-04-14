param location string = resourceGroup().location
param name string
param containerAppEnvironmentId string

param containerImage string
param useExternalIngress bool = false
param containerPort int

param envVars array = []

param acrName string
param acrTokenName string
@secure()
param acrTokenPassword string

param identityId string

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
    name: name
    location: location
    identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
            '${identityId}': {}
        }
    }
    properties: {
        managedEnvironmentId: containerAppEnvironmentId
        configuration: {
            secrets: [
                {
                    name: 'acrtokenpwd'
                    value: acrTokenPassword
                }
            ]
            registries: [
                {
                    server: '${acrName}.azurecr.io'
                    username: acrTokenName
                    passwordSecretRef: 'acrtokenpwd'
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
                    image: containerImage
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
