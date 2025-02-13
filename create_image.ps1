param (
    [string]$subscriptionID = (Get-AzContext).Subscription.Id,
    [string]$imageResourceGroup = "devbox",
    [string]$location = "eastus2",
    [string]$runOutputName = "aibCustWinManImg01",
    [string]$imageDefName = "vscodeImageDef",
    [string]$imageOfferName = "vscodebox",
    [string]$imageSkuName = "1-0-0",
    [string]$imageBuildIdentityName = "AzureImageBuilderId",
    [string]$galleryName = "devboxGallery",
    [string]$companyName = "myCompany",
    [bool]$skipGalleryCreation = $false
)

$SecurityType = @{Name='SecurityType';Value='TrustedLaunch'} 
$features = @($SecurityType)


if (-not $skipGalleryCreation) {
    # Create the image definition
    New-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher $companyName -Offer $imageOfferName -Sku $imageSkuName -Feature $features -HyperVGeneration "V2"
}

$templateFilePath = "./image_template.json"
$temptemplateFilePath = "./image_template_temp.json"

$identityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $imageBuildIdentityName).Id

# Replace the placeholders in the template file with the actual values
(Get-Content -path $templateFilePath -Raw ) -replace '<subscriptionID>', $subscriptionID | Set-Content -Path $temptemplateFilePath -Force
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<rgName>', $imageResourceGroup | Set-Content -Path $temptemplateFilePath 
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<runOutputName>', $runOutputName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<imageDefName>', $imageDefName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<sharedImageGalName>', $galleryName | Set-Content -Path $temptemplateFilePath  
(Get-Content -path $temptemplateFilePath -Raw ) -replace '<region1>', $location | Set-Content -Path $temptemplateFilePath  
((Get-Content -path $temptemplateFilePath -Raw) -replace '<imgBuilderId>', $identityNameResourceId) | Set-Content -Path $temptemplateFilePath

# Invoke the deployment
New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $temptemplateFilePath -Api-Version "2020-02-14" -imageTemplateName $imageDefName -svclocation $location
Invoke-AzResourceAction -ResourceName $imageDefName -ResourceGroupName $imageResourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2020-02-14" -Action Run

# Clean up the temporary file
Remove-Item -Path $temptemplateFilePath -Force

# Wait for the image template to be created
do {
    $status = Get-AzImageBuilderTemplate -ImageTemplateName $imageDefName -ResourceGroupName $imageResourceGroup | Select-Object -ExpandProperty ProvisioningState
    Start-Sleep -Seconds 10
} while ($status -eq "Creating")

Write-Output "Job Finished"