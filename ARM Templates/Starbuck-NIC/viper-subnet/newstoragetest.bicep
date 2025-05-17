param accountType string = 'Standard_LRS'
param location string = resourceGroup().location
param accountName string = uniqueString(resourceGroup().id, 'storageaccount')

resource storageAcc 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: accountType
  }
  properties: {}
}

output storageAccountName string = accountName
output storageAccountId string = storageAcc.id
