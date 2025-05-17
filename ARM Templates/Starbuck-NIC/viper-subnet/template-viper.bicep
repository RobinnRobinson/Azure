param networkInterfaceName string
param location string
param subnetId string
param privateIPAllocationMethod string

@description('Azure region for the deployment, resource group and resources.')
param vnetLocation string = 'australiaeast'
param vnetExtendedLocation object = {}

@description('Name of the virtual network resource.')
param vnetVirtualNetworkName string = 'vnet-starbuck'

@description('Optional tags for the resources.')
param vnetTagsByResource object = {}
param vnetProperties object = {
  provisioningState: 'Succeeded'
  resourceGuid: '5a0c83a1-02db-4f6e-a110-93bb1bc22e48'
  addressSpace: {
    addressPrefixes: [
      '172.16.0.0/16'
    ]
  }
  subnets: [
    {
      name: 'raptor-subnet'
      properties: {
        addressPrefixes: [
          '172.16.2.0/24'
        ]
        ipamPoolPrefixAllocations: []
      }
    }
  ]
  virtualNetworkPeerings: []
  enableDdosProtection: false
}
param vnetNatGatewaysWithNewPublicIpAddress array = []
param vnetNatGatewaysWithoutNewPublicIpAddress array = []

@description('Array of public ip addresses for NAT Gateways.')
param vnetNatGatewayPublicIpAddressesNewNames array = []

@description('Array of NAT Gateway objects for subnets.')
param vnetNetworkSecurityGroupsNew array = []
param vnetResourceGroupName string = 'Caprica'
param vnetDeploymentName string = 'network-interface-associated-virtual-network-20250516185058'

var standardSku = {
  name: 'Standard'
}
var vnetStaticAllocation = {
  publicIPAllocationMethod: 'Static'
}
var vnetPremiumTier = {
  tier: 'Premium'
}
var vnetPublicIpAddressesTags = (contains(vnetTagsByResource, 'Microsoft.Network/publicIpAddresses')
  ? vnetTagsByResource['Microsoft.Network/publicIpAddresses']
  : json('{}'))
var vnetNatGatewayTags = (contains(vnetTagsByResource, 'Microsoft.Network/natGateways')
  ? vnetTagsByResource['Microsoft.Network/natGateways']
  : json('{}'))

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'Ipv4config'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
  tags: {}
  dependsOn: [
    vnetDeployment
  ]
}

module vnetDeployment './nested_vnetDeployment.bicep' = [
  for i in range(0, 1): {
    name: vnetDeploymentName
    scope: resourceGroup(vnetResourceGroupName)
    params: {
      vnetVirtualNetworkName: vnetVirtualNetworkName
      vnetLocation: vnetLocation
      vnetExtendedLocation: vnetExtendedLocation
      vnetTagsByResource: vnetTagsByResource
      vnetProperties: vnetProperties
    }
    dependsOn: [
      vnetNatGatewaysWithNewPublicIpAddress_name
      vnetNatGatewaysWithoutNewPublicIpAddress_name
      vnetNetworkSecurityGroupsNew_name
      vnetNatGatewayPublicIpAddressesNewNames_resource
      vnetNatGatewayPublicIpAddressesNewNames_resource
    ]
  }
]

resource vnetNatGatewaysWithoutNewPublicIpAddress_name 'Microsoft.Network/natGateways@2019-09-01' = [
  for item in vnetNatGatewaysWithoutNewPublicIpAddress: if (length(vnetNatGatewaysWithoutNewPublicIpAddress) > 0) {
    name: item.name
    location: vnetLocation
    tags: vnetNatGatewayTags
    sku: standardSku
    properties: item.properties
  }
]

resource vnetNatGatewaysWithNewPublicIpAddress_name 'Microsoft.Network/natGateways@2019-09-01' = [
  for item in vnetNatGatewaysWithNewPublicIpAddress: if (length(vnetNatGatewaysWithNewPublicIpAddress) > 0) {
    name: item.name
    location: vnetLocation
    tags: vnetNatGatewayTags
    sku: standardSku
    properties: item.properties
    dependsOn: [
      vnetNatGatewayPublicIpAddressesNewNames_resource
    ]
  }
]

resource vnetNatGatewayPublicIpAddressesNewNames_resource 'Microsoft.Network/publicIpAddresses@2022-05-01' = [
  for item in vnetNatGatewayPublicIpAddressesNewNames: if (length(vnetNatGatewayPublicIpAddressesNewNames) > 0) {
    name: item
    location: vnetLocation
    sku: standardSku
    tags: vnetPublicIpAddressesTags
    properties: vnetStaticAllocation
  }
]

resource vnetNetworkSecurityGroupsNew_name 'Microsoft.Network/networkSecurityGroups@2020-05-01' = [
  for item in vnetNetworkSecurityGroupsNew: if (length(vnetNetworkSecurityGroupsNew) > 0) {
    name: item.name
    location: vnetLocation
    tags: (contains(vnetTagsByResource, 'Microsoft.Network/networkSecurityGroups')
      ? vnetTagsByResource['Microsoft.Network/networkSecurityGroups']
      : json('{}'))
    properties: {}
  }
]
