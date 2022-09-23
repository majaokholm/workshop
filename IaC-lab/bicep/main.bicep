// // targetScope = 'subscription'
// // param RgName string

param storageAccName string = '{substring('saava-${uniqueString(resourceGroup().id)}', 0, 24)}'

var location = deployment().location // set same location as the deployment
// // deploy resource group
/// if you deploy to subscription level, you can deploy a RG too
// resource RgName 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//   name: 'myapp-rg'
//   location: location
// }

// deploy storage account to resource group
module str 'modules/storageAccount.bicep' {
  name: 'storage'
  scope: RgName
  params: {
    name: 'str39465131'
  }
}

output resourceGroup object = RgName
output storageAccountName string = str.outputs.storageAccountName
