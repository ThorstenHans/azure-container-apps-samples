// general Azure Container App settings
param location string
param name string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
    name: name
    location: location
    properties: {
        managedEnvironmentId: containerAppEnvironmentId
        configuration: {
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
                    env: [
                        {
                            name: 'PORT'
                            value: '${containerPort}'
                        }
                    ]
                    probes: [
                        {
                            type: 'liveness'
                            initialDelaySeconds: 15
                            periodSeconds: 30
                            failureThreshold: 3
                            timeoutSeconds: 1
                            httpGet: {
                                port: containerPort
                                path: '/healthz/liveness'
                            }
                        }
                        {
                            type: 'startup'
                            timeoutSeconds: 2
                            httpGet: {
                                port: containerPort
                                path: '/healthz/startup'
                            }
                        }
                        {
                            type: 'readiness'
                            timeoutSeconds: 3
                            failureThreshold: 3
                            httpGet: {
                                port: containerPort
                                path: '/healthz/readiness'
                            }
                        }
                    ]
                }
            ]
            scale: {
                minReplicas: 12
            }
        }
    }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
