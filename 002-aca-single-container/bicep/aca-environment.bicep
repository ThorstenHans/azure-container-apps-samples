param name string
param location string
param lawClientId string
param lawClientSecret string

// this namespace will change in March 2022 (now :D) Microsoft.Apps
resource env 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: name
  location: location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}
output id string = env.id
