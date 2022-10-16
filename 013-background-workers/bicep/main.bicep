param location string = resourceGroup().location
param name string = 'background-worker'
param storageAccountName string = 'saacabackgroundworker'
param dockerUserName string = 'thorstenhans'

param apiRepository string = 'aca-background-worker-api'
param apiTag string = 'latest'
param containerPortApi int = 5000

param workerRepository string = 'aca-background-worker'
param workerTag string = 'latest'

var queueName = 'work'
var resultsContainerName = 'results'

module containerAppEnvironment 'environment.bicep' = {
    name: 'container-app-environment'
    params: {
        name: 'env-${name}'
        location: location
    }
}

module storageAccount 'storage-account.bicep' = {
    name: 'storage-account'
    params: {
        name: storageAccountName
        location: location
        resultsContainerName: resultsContainerName
    }
}

module serviceBus 'service-bus.bicep' = {
    name: 'service-bus'
    params: {
        name: 'thns${name}'
        location: location
        queueName: queueName
    }
}

module app_api 'aca.bicep' = {
    name: 'app-api'
    params: {
        name: 'api'
        location: location
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: '${dockerUserName}/${apiRepository}:${apiTag}'
        containerPort: containerPortApi
        secrets: [
            {
                name: 'service-bus-connection-string'
                value: serviceBus.outputs.ServiceBusConnectionString
            }
        ]
        envVars: [
            {
                name: 'QueueConfig__QueueName'
                value: queueName
            }
            {
                name: 'QueueConfig__ConnectionString'
                secretRef: 'service-bus-connection-string'
            }
        ]
        useExternalIngress: true

        minReplicas: 1
        maxReplicas: 1
        scaleRules: []
    }
}

module app_worker 'aca.bicep' = {
    name: 'app-worker'
    params: {
        location: location
        name: 'worker'
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: '${dockerUserName}/${workerRepository}:${workerTag}'
        secrets: [
            {
                name: 'storage-account-connection-string'
                value: storageAccount.outputs.StorageAccountConnectionString
            }
            {
                name: 'service-bus-connection-string'
                value: serviceBus.outputs.ServiceBusConnectionString
            }
        ]
        envVars: [
            {
                name: 'QueueConfig__QueueName'
                value: queueName
            }
            {
                name: 'QueueConfig__ConnectionString'
                secretRef: 'service-bus-connection-string'
            }
            {
                name: 'BlobConfig__ContainerName'
                value: resultsContainerName
            }
            {
                name: 'BlobConfig__ConnectionString'
                secretRef: 'storage-account-connection-string'
            }
        ]
        useExternalIngress: false
        
        minReplicas: 0
        maxReplicas: 10
        scaleRules: [
            {
                name: 'queue-trigger'
                custom: {
                    type: 'azure-servicebus'
                    metadata: {
                        queueName: queueName
                        messageCount: '5'
                    }
                    auth: [{
                        secretRef: 'service-bus-connection-string'
                        triggerParameter: 'connection'
                    }]
                }
            }
        ]
    }
}

output fqdn string = app_api.outputs.fqdn
