param acrName string = 'acamissample'
param acrTokenName string = 'acaPull'
@secure()
param acrTokenPassword string

param appCfgName string = 'appcfg-aca-msi'

param containerImage string = '${acrName}.azurecr.io/api:0.0.1'
param containerPort int = 5000

param location string = resourceGroup().location

@description('User assigned managed identity id')
param identityId string
param identityClientId string 

var appCfgEndpoint = 'https://${appCfgName}.azconfig.io'

module law 'modules/log-analytics.bicep' = {
    name: 'log-analytics-workspace'
    params: {
        location: location
        name: 'law-aca-msi-sample'
    }
}

module containerAppEnvironment 'modules/container-app-env.bicep' = {
    name: 'container-app-environment'
    params: {
        name: 'env-msi-sample'
        location: location
        lawClientId: law.outputs.clientId
        lawClientSecret: law.outputs.clientSecret
    }
}

// dd
module containerApp 'modules/container-app.bicep' = {
    name: 'container-app'
    params: {
        name: 'storage-browser'
        location: location
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: containerImage
        containerPort: containerPort
        acrName: acrName
        acrTokenName: acrTokenName
        acrTokenPassword: acrTokenPassword
        identityId: identityId
        envVars: [
            {
                name: 'AZ_APPCFG_ENDPOINT'
                value: appCfgEndpoint
            }
            {
                name: 'MSI_CLIENT_ID'
                value: identityClientId
            }
        ]
        useExternalIngress: true
    }
}

output fqdn string = containerApp.outputs.fqdn
