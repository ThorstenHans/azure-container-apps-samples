param location string = resourceGroup().location
param name string = 'multi-container'

param facadeServiceImage string = 'facade:latest'
param facadeServicePort int = 8080
param isFacadeServiceExternalIngress bool = true

param orderServiceImage string = 'orders:latest'
param orderServicePort int = 8080
param isOrderServiceExternalIngress bool = false

param inventoryServiceImage string = 'inventory:latest'
param inventoryServicePort int = 8080
param isInventoryServiceExternalIngress bool = false

param containerRegistry string = 'acawebinar.azurecr.io'
param containerRegistryUsername string = 'acawebinar'

@secure()
param containerRegistryPassword string

var facadeServiceName = 'facade-api'
var orderServiceName = 'order-api'
var inventoryServiceName = 'inventory-api'

module environment 'environment.bicep' = {
    name: 'container-app-environment'
    params: {
        environmentName: 'env-${name}'
        location: location
    }
}

module cosmosdb 'db.bicep' = {
    name: 'cosmosdb'
    params: {
        location: location
        primaryRegion: location
    }
}

module daprStateStore 'dapr.bicep' = {
    name: 'dapr-state-store'
    params: {
        containerAppEnvironmentName: 'env-${name}'
        cosmosDbDocumentEndpoint: cosmosdb.outputs.documentEndpoint
        cosmosDbMasterKey: cosmosdb.outputs.primaryMasterKey
        scopes: [
            orderServiceName
        ]
    }
}
module orderService 'aca.bicep' = {
    name: orderServiceName
    params: {
        location: location
        containerAppName: orderServiceName
        environmentId: environment.outputs.environmentId
        containerImage: orderServiceImage
        containerPort: orderServicePort
        isExternalIngress: isOrderServiceExternalIngress
        containerRegistry: containerRegistry
        containerRegistryUsername: containerRegistryUsername
        containerRegistryPassword: containerRegistryPassword
        secrets: [
            {
                name: 'docker-password'
                value: containerRegistryPassword
            }
        ]
    }
}

module inventoryService 'aca.bicep' = {
    name: inventoryServiceName
    params: {
        location: location
        containerAppName: inventoryServiceName
        environmentId: environment.outputs.environmentId
        containerImage: inventoryServiceImage
        containerPort: inventoryServicePort
        isExternalIngress: isInventoryServiceExternalIngress
        containerRegistry: containerRegistry
        containerRegistryUsername: containerRegistryUsername
        containerRegistryPassword: containerRegistryPassword
    }
}

module facadeService 'aca.bicep' = {
    name: facadeServiceName
    params: {
        location: location
        containerAppName: facadeServiceName
        environmentId: environment.outputs.environmentId
        containerImage: facadeServiceImage
        containerPort: facadeServicePort
        isExternalIngress: isFacadeServiceExternalIngress
        containerRegistry: containerRegistry
        containerRegistryUsername: containerRegistryUsername
        containerRegistryPassword: containerRegistryPassword
        env: [
            {
                name: 'ORDER_SERVICE_NAME'
                value: orderServiceName
            }
            {
                name: 'INVENTORY_SERVICE_NAME'
                value: inventoryServiceName
            }
        ]
    }
}

output facadeServiceFqdn string = facadeService.outputs.fqdn
output orderServiceFqdn string = orderService.outputs.fqdn
output inventoryServiceFqdn string = inventoryService.outputs.fqdn
