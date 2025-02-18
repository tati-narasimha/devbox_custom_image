# Networking Bicep Modules

This directory contains Bicep modules for setting up network connections and role assignments for the DevBox environment.

## Files

- `network_connection.bicep`: Defines the network connection for the DevBox.
- `role_assignment.bicep`: Assigns the necessary roles to the subnet for the DevBox.

## Deployment Examples

### Deploy `network_connection.bicep`

This module sets up the network connection for the DevBox.

#### Parameters

- `devbox_network_id` (string): The ID of the subnet.
- `devbox_network_location` (string): The location of the network.
- `devbox_network_rg` (string): The resource group of the network. Default is `devbox_network_rg`.

#### Example Deployment

```sh
az deployment group create \
    --resource-group myResourceGroup \
    --template-file network_connection.bicep \
    --parameters devbox_network_id="/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>" \
                 devbox_network_location="eastus2" \
                 devbox_network_rg="myResourceGroup"
```

### Deploy `role_assignment.bicep`

This module assigns the necessary roles to the subnet for the DevBox.

#### Parameters

- `principalId` (string): The ID of the principal to assign the role to.
- `subnetId` (string): The ID of the subnet.

#### Example Deployment

```sh
az deployment group create \
    --resource-group myResourceGroup \
    --template-file role_assignment.bicep \
    --parameters principalId="<principal-id>" \
                 subnetId="/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
```
