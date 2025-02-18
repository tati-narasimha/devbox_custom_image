param principalId string
param subnetId string

var network_contributor_role_id = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource devbox_subnet_id 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  name: subnetId
}

resource devbox_network_join_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: 'devbox-network-join-custom-role'
  scope: devbox_subnet_id
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', network_contributor_role_id)
  }
}
