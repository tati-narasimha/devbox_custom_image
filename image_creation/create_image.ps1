param (
    [string]$subscriptionID = (Get-AzContext).Subscription.Id,
    [string]$resourceGroup = "devbox",
    [string]$location = "eastus2",
    [string]$imageName = "myWindowsImage",
    [string]$imageSkuName = "1-0-0",
    [string]$imageBuildIdentityName = "AzureImageBuilderId",
    [string]$galleryName = "devboxGallery",
    [string]$companyName = "myCompany",
    [bool]$skipGalleryCreation = $false
)

$SecurityType = @{Name='SecurityType';Value='TrustedLaunch'} 
$features = @($SecurityType)

$timeInt = (get-date -UFormat "%s") 
$runOutputName = "$imageName" + $timeInt

if (-not $skipGalleryCreation) {
    # Create the image definition
    New-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $resourceGroup -Location $location -Name $imageName -OsState generalized -OsType Windows -Publisher $companyName -Offer $imageName -Sku $imageSkuName -Feature $features -HyperVGeneration "V2"
}

$templateFilePath = "./image_template.json"
$temptemplateFilePath = "./image_template_temp.json"

$identityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroup -Name $imageBuildIdentityName).Id

# Replace the placeholders in the template file with the actual values
(Get-Content -path $templateFilePath -Raw ) -replace '<subscriptionID>', $subscriptionID | Set-Content -Path $temptemplateFilePath -Force
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<rgName>', $resourceGroup | Set-Content -Path $temptemplateFilePath 
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<runOutputName>', $runOutputName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<imageName>', $imageName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<sharedImageGalName>', $galleryName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<region1>', $location | Set-Content -Path $temptemplateFilePath  
((Get-Content -path $temptemplateFilePath -Raw) -replace '<imgBuilderId>', $identityNameResourceId) | Set-Content -Path $temptemplateFilePath

# Invoke the deployment
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $temptemplateFilePath -Api-Version "2020-02-14" -imageTemplateName $imageName -svclocation $location
Invoke-AzResourceAction -ResourceName $imageName -ResourceGroupName $resourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2020-02-14" -Action Run

# Clean up the temporary file
Remove-Item -Path $temptemplateFilePath -Force

# Wait for the image template to be created
do {
    $status = Get-AzImageBuilderTemplate -ImageTemplateName $imageName -ResourceGroupName $resourceGroup | Select-Object -ExpandProperty ProvisioningState
    Start-Sleep -Seconds 10
} while ($status -eq "Creating")

Write-Output "Job Finished"