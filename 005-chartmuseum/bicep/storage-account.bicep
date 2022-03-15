param location string
param name string
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

resource mainstoragecontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
    name: '${sa.name}/default/charts'
}

output storage_account_access_key string = sa.listKeys().keys[0].value
