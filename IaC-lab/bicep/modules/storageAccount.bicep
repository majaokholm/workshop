param storageName string

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
}

output storageAccountName string = storage.name
