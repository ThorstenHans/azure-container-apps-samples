param location string = resourceGroup().location
param envName string = 'chartmuseum'
param storageAccountName string = 'sachartmuseumaca'
param containerImage string = 'chartmuseum/chartmuseum:latest'
param containerPort int = 8080
param adminUser string = 'demouser'
param adminPassword string
module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: 'law-${envName}'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId: law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module storageAccount 'storage-account.bicep' = {
    name: storageAccountName
    params: {
        name: storageAccountName
        location: location
    }
}

module containerApp 'aca.bicep' = {
  name: 'chartmuseum'
  params: {
    name: 'chartmuseum'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    secrets: [
        {
            name: 'basic-auth-password'
            value: adminPassword
        }
        {
            name: 'storage-account-access-key'
            value: storageAccount.outputs.storage_account_access_key
        }
    ]
    envVars: [
        {
            name: 'PORT'
            value: '${containerPort}'
        }
        { 
            name: 'AUTH_ANONYMOUS_GET'
            value: '1'
        }
        {
            name: 'BASIC_AUTH_USER'
            value: adminUser
        }
        {
            name: 'BASIC_AUTH_PASS'
            secretRef: 'basic-auth-password'
        }
        {
            name: 'STORAGE'
            value: 'microsoft'
        }
        {
            name: 'STORAGE_MICROSOFT_CONTAINER'
            value: 'charts'
        }
        {
            name: 'STORAGE_MICROSOFT_PREFIX'
            value: ''
        }
        {
            name: 'AZURE_STORAGE_ACCOUNT'
            value: storageAccountName
        }
        {
            name: 'AZURE_STORAGE_ACCESS_KEY'
            secretRef: 'storage-account-access-key'
        }
    ]
    useExternalIngress: true
  }
}

output fqdn string = containerApp.outputs.fqdn
