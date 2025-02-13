# DevBox Custom Image
This repository contains PowerShell scripts to create and manage custom images for a development environment using Azure Image Builder.

## Overview

Creating a DevBox Custom Image involves several steps, including setting up the environment, creating a Shared Image Gallery, defining the image template, and building the image. This process is based on the steps described in the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder).

## Prerequisites

- Azure PowerShell module
- Azure subscription
- Appropriate permissions to create and manage resources in Azure

## Scripts

### 1. install_prerequisites.ps1

This script installs the necessary modules and sets up the environment for creating custom images.

#### Parameters

- `subscriptionID` (string): The Azure subscription ID. Default is the current context subscription ID.
- `imageResourceGroup` (string): The resource group for the image. Default is "devbox".
- `location` (string): The location for the resources. Default is "eastus2".
- `galleryName` (string): The name of the gallery. Default is "devboxGallery".

#### Usage

```powershell
.\install_prerequisites.ps1
```

### 2. Create your gallery
```powershell
New-AzGallery -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $locationAzure
```

### 2. create_image.ps1

This script creates the image definition and builds the custom image.

#### Parameters

- `subscriptionID` (string): The Azure subscription ID. Default is the current context subscription ID.
- `imageResourceGroup` (string): The resource group for the image. Default is "devbox".
- `location` (string): The location for the resources. Default is "eastus2".
- `runOutputName` (string): The name of the run output. Default is "aibCustWinManImg01".
- `imageDefName` (string): The name of the image definition. Default is "vscodeImageDef".
- `imageTemplateName` (string): The name of the image template. Default is "vscodeWinTemplate".
- `imageOfferName` (string): The name of the image offer. Default is "vscodebox".
- `imageSkuName` (string): The SKU name of the image. Default is "1-0-0".
- `imageBuildIdentityName` (string): The name of the image build identity. Default is "AzureImageBuilderId".
- `galleryName` (string): The name of the gallery. Default is "devboxGallery".
- `companyName` (string): The name of the company. Default is "myCompany".

#### Usage

```powershell
 .\create_image.ps1 -imageBuildIdentityName azImageBuilderId -companyName schneider -galleryName schneidergallery -skipGalleryCreation $true
```

## Summary of Steps

1. **Set up the environment**: Ensure you have the necessary prerequisites and permissions.
2. **Install prerequisites**: Use `install_prerequisites.ps1` to install the necessary modules and set up the environment.
3. **Create and build the image**: Use `create_image.ps1` to create the image definition and build the custom image.

For detailed instructions, refer to the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder).
