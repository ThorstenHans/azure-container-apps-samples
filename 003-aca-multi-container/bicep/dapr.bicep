param containerAppEnvironmentName string

@secure()
param cosmosDbMasterKey string
param cosmosDbDocumentEndpoint string

param scopes array

resource daprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
    name: '${containerAppEnvironmentName}/orders'
    properties: {
        componentType: 'state.azure.cosmosdb'
        version: 'v1'
        ignoreErrors: false
        initTimeout: '5s'
        secrets: [
            {
                name: 'masterkey'
                value: cosmosDbMasterKey
            }
        ]
        metadata: [
            {
                name: 'url'
                value: cosmosDbDocumentEndpoint
            }
            {
                name: 'database'
                value: 'ordersDb'
            }
            {
                name: 'collection'
                value: 'orders'
            }
            {
                name: 'masterkey'
                secretRef: 'masterkey'
            }
        ]
        scopes: scopes
    }
}
