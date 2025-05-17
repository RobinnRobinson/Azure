// Setting up the parameters for the storage account
param location string = resourceGroup().location
// will take the location of the resource group it's deployed to

// The name of the storage account must be between 3 and 24 characters in length
// minLength and maxLength are used to set the minimum and maximum length of the name
// these must be put before the parameter name
@minLength(3)
@maxLength(24)
param name string = 'robinsstorage248'

// The allowed SKUs for the storage account
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_ZRS'
])
param type string = 'Standard_LRS'

var containerName = 'images'

// Creating a resource

// Giving the resource a name/symbolic name
// Not the name as the resource in Azure. It's the name of the resource in Bicep file to refference it.
resource staccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: type
  }
}

// Creating a container in the storage account and it needs to be dependent on the storage account
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  // The name will refer to the name of the storage account
  // It will create a container named images in the storage account
  // ${staccount.name} references the name of the storage account, it depends on it
  // created a variable for the container name as images var containerName above
  name: '${staccount.name}/default/${containerName}'
}

// It outputs the storage account ID when created
// The output will be used in the main.bicep file to reference the storage account
// storageID is symbolic name of the output (can be anything)
output storageID string = staccount.id
