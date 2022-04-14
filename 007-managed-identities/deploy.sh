#!/bin/bash

set -e

loc=northeurope
rgName=rg-aca-msi-sample
saName=saacamsisample
containerName=blobs
acrName=acamsisample
appCfgName=appcfg-aca-msi

# Create the Azure Resource Group
az group create -n $rgName -l $loc

# Create the Azure Storage Account
saId=$(az storage account create -n $saName -g $rgName --sku Standard_LRS --kind StorageV2 --query "id" -otsv)

# Grab Account Key
saKey=$(az storage account keys list -n $saName --query "[0].value" -otsv)

# Create Blob Container
az storage container create -n $containerName --account-name $saName --account-key $saKey

# Upload Sample Blobs
az storage blob upload -f ./sample-blobs/blob1.txt -c blobs --account-name $saName --account-key $saKey
az storage blob upload -f ./sample-blobs/blob2.json -c blobs --account-name $saName --account-key $saKey

# Create the Azure App Configuration
appCfgId=$(az appconfig create -g $rgName -n $appCfgName -l $loc --query "id" -otsv)
appCfgName=$(az appconfig show -g aca-msi-sample -n appcfg-aca-msi --query "name" -otsv)

# Store Storage Account name and container name in Azure App Configuration
az appconfig kv set -n $appCfgName --key sotrage_account_name --value $saName --yes -onone
az appconfig kv set -n $appCfgName --key blob_container_name --value $containerName --yes -onone

# Create the Azure Container Registry
az acr create -n $acrName -g $rgName --sku Premium --admin-enabled false -onone

# Create an ACR Token
az acr token create -n acaPull -r $acrName --scope-map _repositories_pull --status enabled -onone

# Generate a password for the ACR token
acrTokenPassword=$(az acr token credential generate -n acaPull \
 -r $acrName \
 --expiration-in-days 14 \
 --password1 \
 --query "passwords[0].value" \
 -otsv)

# Create a user-assigned MSI
msiId=$(az identity create -n id-aca -g $rgName -l $loc --query "id" -otsv)
msiClientId=$(az identity show -n id-aca -g $rgName --query "clientId" -otsv)

# Create role assignments for the user-assigned MSI
az role assignment create --scope $appCfgId --assignee $msiId --role "App Configuration Data Reader" -onone
az role assignment create --scope $saId --assignee $msiId --role "Storage Blob Data Reader" -onone

echo ""
echo "Starting Azure Container Apps Deployment..."
az deployment group create -g aca-msi-sample -f ./bicep/main.bicep --parameters acrName=$acrName acrTokenPassword=$acrTokenPassword acrTokenName=acaPull identityId=$msiId identityClientId=$msiClientId appCfgName=$appCfgName --query properties.outputs.fqdn.value -otsv

