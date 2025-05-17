// Parameters
param location string = 'australiaeast'
param vnetName string = 'vnet-starbuck'
param subnetName string = 'raptor-subnet'
param networkInterfaceName string = 'raptor-nic'

// Creating a virtual network

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '172.16.2.0/24'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'raptor-nic'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            //id: '/subscriptions/539956e5-5758-4be7-94f0-eebeae6ac67d/resourcegroups/Caprica/providers/Microsoft.Network/virtualNetworks/vnet-starbuck'
            id: vnet.properties.subnets[0].id
            //id: '/subscriptions/539956e5-5758-4be7-94f0-eebeae6ac67d/resourcegroups/Caprica/providers/Microsoft.Network/virtualNetworks/vnet-starbuck
          }
        }
      }
    ]
  }
}
