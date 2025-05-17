@description('Name of the virtual network resource.')
param vnetVirtualNetworkName string

@description('Azure region for the deployment, resource group and resources.')
param vnetLocation string
param vnetExtendedLocation object

@description('Optional tags for the resources.')
param vnetTagsByResource object
param vnetProperties object

resource vnetVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetVirtualNetworkName
  location: vnetLocation
  extendedLocation: (empty(vnetExtendedLocation) ? json('null') : vnetExtendedLocation)
  tags: (empty(vnetTagsByResource) ? json('{}') : vnetTagsByResource)
  properties: vnetProperties
}
