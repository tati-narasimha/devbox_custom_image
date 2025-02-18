param devbox_network_id string
param devbox_network_location string
param devbox_network_rg string = 'devbox_network_rg'


resource devbox_network_connection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' = {
  name: 'devbox-network-connection'
  properties: {
    subnetId: devbox_network_id
    domainJoinType: 'AzureADJoin'
    networkingResourceGroupName: devbox_network_rg
  }
  location: devbox_network_location
}
