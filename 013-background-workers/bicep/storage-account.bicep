param name string
param location string = resourceGroup().location
param resultsContainerName string = 'results'

resource sa 'Microsoft.Storage/storageAccounts@2021-08-01' = {
    kind: 'StorageV2'
    name: name
    location: location
    sku: {
        name: 'Standard_LRS'
    }
    properties: {
        allowBlobPublicAccess: false
        accessTier: 'Hot'
        isHnsEnabled: false
        isSftpEnabled: false
    }
}

resource results_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
    name: '${sa.name}/default/${resultsContainerName}'
}

var cstr = 'DefaultEndpointsProtocol=https;AccountName=${sa.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(sa.id, sa.apiVersion).keys[0].value}'

output StorageAccountConnectionString string = cstr
output StorageAccountName string = sa.name
