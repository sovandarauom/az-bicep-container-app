@description('Name of the log analytics workspace')
param logAnalyticsName string

@description('Name of the connected Container Registry')
param containerRegistryName string

@description('Name of the Container App Environment')
param containerAppEnvName string

@description('Name of the TodoApi Container App')
param todoApiContainerName string

param location string = resourceGroup().location

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerAppEnvironment 'Microsoft.Web/kubeEnvironments@2022-09-01' = {
  name: containerAppEnvName
  location: location 
  kind: 'containerenvironment'
  properties: {
    environmentType: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource todoApiContainerApp 'Microsoft.Web/containerApps@2022-09-01' = {
  name: todoApiContainerName
  location: location
  properties: {
    kubeEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          server: containerRegistry.name
          username: containerRegistry.properties.loginServer
          passwordSecretRef: 'container-registry-password'
        }
      ]
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
    }
    template: {
      containers: [
        {
          name: todoApiContainerName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }         
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
