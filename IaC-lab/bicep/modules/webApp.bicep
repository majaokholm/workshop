param AppSvcPlanName string // App Service Plan name should be unique within the resource group, opting for the simple 'refname' property
param AppSvcName string // Web application name should be globally unique - so pass something with  substring('plan-ava-${uniqueString(resourceGroup().id)}', 0, 24)

param location string = resourceGroup().location
param tags object


resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: AppSvcPlanName
  location: location
  tags: tags
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: AppSvcName
  location: location
  tags: union({
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${appServicePlan.name}': 'Resource'
  }, tags)
  properties: {
    serverFarmId: appServicePlan.id
  }
}
