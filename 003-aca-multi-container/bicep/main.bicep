param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

param facadeServiceImage string = 'acawebinar.azurecr.io/facade:0.0.7'
param facadeServicePort int = 8080
param isFacadeServiceExternalIngress bool = true

param orderServiceImage string = 'acawebinar.azurecr.io/orders:0.0.12'
param orderServicePort int = 8080
param isOrderServiceExternalIngress bool = false

param inventoryServiceImage string = 'acawebinar.azurecr.io/inventory:0.0.4'
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
        environmentName: environmentName
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
        containerAppEnvironmentName: environmentName
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
