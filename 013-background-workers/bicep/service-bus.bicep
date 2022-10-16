param name string
param location string = resourceGroup().location
param queueName string = 'work' 

resource sb 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
    name: 'sbn-${name}'
    location: location
    sku: {
        name: 'Standard'
    }
    properties: {
        publicNetworkAccess: 'Enabled'
    }
}

resource sbQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
    name: '${sb.name}/${queueName}'
    properties: {
        lockDuration: 'PT5M'
        defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
        duplicateDetectionHistoryTimeWindow: 'PT10M'
        maxDeliveryCount: 10
        enableBatchedOperations: true
        requiresSession: false
        requiresDuplicateDetection: false
        deadLetteringOnMessageExpiration: true
        enablePartitioning: false
        status: 'Active'
    }
} 
var serviceBusEndpoint = '${sb.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, sb.apiVersion).primaryConnectionString

output ServiceBusConnectionString string = serviceBusConnectionString
output ServiceBusName string = sb.name
