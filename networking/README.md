# Networking Bicep Modules

This directory contains Bicep modules for setting up network connections and role assignments for the DevBox environment.

## Files

- `network_connection.bicep`: Defines the network connection for the DevBox.
- `role_assignment.bicep`: Assigns the necessary roles to the subnet for the DevBox.

## Deployment Examples

### Create Service Principal to create Managed Connection
## Creating a Service Principal with Azure CLI

To create a service principal using Azure CLI, you can use the `az ad sp create-for-rbac` command. This command creates a service principal and assigns a role-based access control (RBAC) role to it. The service principal can then be used to authenticate and authorize applications or scripts to access Azure resources.

### Command Syntax

```sh
az ad sp create-for-rbac --name <name> --role <role> --scopes <scope>
```

### Example

```sh
az ad sp create-for-rbac --name myServicePrincipal 
```

This example creates a service principal named `myServicePrincipal` 

### Role Assignments for Managed Network

As part of the process to create a managed network pointing to a subnet in another subscription, you need to assign roles to the subnet and the resource group hosting the Dev Center. Specifically, you will assign the `Network Contributor` role to the subnet and the `Contributor` role to the resource group.

#### Assign `Network Contributor` Role to Subnet

```sh
az role assignment create \
    --assignee <service-principal-id> \
    --role "Network Contributor" \
    --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>
```

#### Assign `Contributor` Role to Resource Group

```sh
az role assignment create \
    --assignee <service-principal-id> \
    --role "Contributor" \
    --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>
```

Replace `<service-principal-id>`, `<subscription-id>`, `<resource-group>`, `<vnet-name>`, and `<subnet-name>` with the appropriate values for your environment.

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