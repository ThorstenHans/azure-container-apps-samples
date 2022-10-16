param name string
param location string = resourceGroup().location
param containerAppEnvironmentId string
param containerImage string
param containerPort int = 80

param useExternalIngress bool = false


param envVars array = []

param secrets array = []
param minReplicas int = 0
param maxReplicas int = 1
param scaleRules array = []

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
    name: name
    location: location
    properties: {
        managedEnvironmentId: containerAppEnvironmentId
        configuration: {
            ingress: useExternalIngress ? {
                external: useExternalIngress
                targetPort: containerPort
            } : null

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
                minReplicas: minReplicas
                maxReplicas: maxReplicas
                rules: scaleRules
            }
        }
    }
}

output fqdn string = useExternalIngress? containerApp.properties.configuration.ingress.fqdn: ''
