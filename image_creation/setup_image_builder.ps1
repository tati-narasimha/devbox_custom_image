param (
    [string]$subscriptionID = (Get-AzContext).Subscription.Id,
    [string]$resourceGroup = "devbox",
    [string]$location = "eastus2"
)

# Verify and Register Resource Providers if not registered
$providers = @(
   "Microsoft.VirtualMachineImages",
   "Microsoft.Storage",
   "Microsoft.Compute",
   "Microsoft.KeyVault",
   "Microsoft.Network"
)

foreach ($provider in $providers) {
   $providerState = Get-AzResourceProvider -ProviderNamespace $provider | Select-Object -ExpandProperty RegistrationState
   if ($providerState -ne "Registered") {
      Write-Output "Registering $provider..."
      Register-AzResourceProvider -ProviderNamespace $provider
   } else {
      Write-Output "$provider is already registered."
   }
}

# Create a user-assigned identity and set permissions on the resource group. 
# VM Image Builder uses the user identity you provide to store the image in Azure Compute Gallery. 

# Set up role definition names, which need to be unique 
$timeInt = (get-date -UFormat "%s") 
$imageRoleDefName = "Azure Image Builder Image Role Def" + $timeInt 
$identityName = "azImageBuilderId"

Write-Output "Azure Image Builder Identity Name: $identityName"

# Create an identity 
New-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $identityName -Location $location

$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $identityName).PrincipalId

# Assign permissions for the identity to distribute the images.
$aibRoleImageCreationUrl = "https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json" 
$aibRoleImageCreationPath = "aibRoleImageCreation.json"

# Download the configuration 
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing 
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>', $subscriptionID) | Set-Content -Path $aibRoleImageCreationPath 
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<rgName>', $resourceGroup) | Set-Content -Path $aibRoleImageCreationPath 
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath

# Create a role definition 
New-AzRoleDefinition -InputFile ./aibRoleImageCreation.json

# Grant the role definition to the VM Image Builder service principal 
New-AzRoleAssignment -ObjectId $identityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroup"