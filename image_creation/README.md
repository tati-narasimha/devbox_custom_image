# DevBox Custom Image
This repository contains PowerShell scripts to create and manage custom images for a development environment using Azure Image Builder.

## Overview

Creating a DevBox Custom Image involves several steps, including setting up the environment, creating a Shared Image Gallery, defining the image template, and building the image. This process is based on the steps described in the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder).

## Prerequisites

- Azure PowerShell module

```powershell
# Install Prerequisites
Install-Module -Name Az -Repository PSGallery -AllowClobber -Scope CurrentUser
'Az.ImageBuilder', 'Az.ManagedServiceIdentity' | ForEach-Object {Install-Module -Name $_ -AllowPrerelease}
```

- Connect to your Azure subscription using `Connect-AzAccount` https://learn.microsoft.com/en-us/powershell/azure/authenticate-interactive?view=azps-13.1.0
- Azure subscription
- Appropriate permissions to create and manage resources in Azure

## Scripts

### 1. setup_image_builder.ps1

This script installs the necessary modules and sets up the environment for creating custom images.

#### Parameters

- `subscriptionID` (string): The Azure subscription ID. Default is the current context subscription ID.
- `resourceGroup` (string): The resource group for the image. Default is "devbox".
- `location` (string): The location for the resources. Default is "eastus2".

#### Usage

```powershell
.\setup_image_builder.ps1 -location centralindia -resourceGroup myresourceGroup
```

### 2. Create your gallery
```powershell
New-AzGallery -GalleryName $galleryName -ResourceGroupName $resourceGroup -Location $locationAzure
```

### 2. create_image.ps1

This script creates the image definition and builds the custom image.

#### Parameters

- `subscriptionID` (string): The Azure subscription ID. Default is the current context subscription ID.
- `resourceGroup` (string): The resource group for the image. Default is "devbox".
- `location` (string): The location for the resources. Default is "eastus2".
- `imageName` (string): The name of the image. Default is "myWindowsImage".
- `imageSkuName` (string): The SKU name of the image. Default is "1-0-0".
- `imageBuildIdentityName` (string): The name of the image build identity. Default is "AzureImageBuilderId".
- `galleryName` (string): The name of the gallery. Default is "devboxGallery".
- `companyName` (string): The name of the company. Default is "myCompany".
- `skipGalleryCreation` (bool): Whether to skip the gallery creation. Default is `$false`.

#### Usage

```powershell
 .\create_image.ps1 -imageBuildIdentityName azImageBuilderId -companyName myCompany -galleryName schneidergallery -skipGalleryCreation $false
```

## Summary of Steps

1. **Set up the environment**: Ensure you have the necessary prerequisites and permissions.
2. **Install prerequisites**: Use `setup_image_builder.ps1` to install the necessary modules and set up the environment.
3. **Create and build the image**: Use `create_image.ps1` to create the image definition and build the custom image.

For detailed instructions, refer to the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder).
