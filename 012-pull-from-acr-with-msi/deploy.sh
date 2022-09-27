#!/bin/bash

set -e

rgName="rg-aca-pull-via-msi"
location="northeurope"
acrName="acasample12"
identityName="id-aca-pull-via-msi"
echo "Creating Resource Group..."
az group create -n $rgName -l $location

echo "Creating Container Registry..."
az acr create -n $acrName -g $rgName --sku Basic --admin-enabled false
docker pull nginx:alpine
docker tag nginx:alpine acasample12.azurecr.io/nginx:alpine
az acr login -n acasample12
docker push acasample12.azurecr.io/nginx:alpine

echo "Creating user-assigned identity"
az identity create -n $identityName -g $rgName -l $location
msiId=$(az identity show -n $identityName -g $rgName --query 'principalId' -o tsv)
acrId=$(az acr show -n $acrName --query 'id' -o tsv)
echo "Assigning ACR pull role to identity"
az role assignment create --assignee-object-id $msiId --role AcrPull --scope $acrId

echo ""
echo "Starting Azure Container Apps Deployment..."
az deployment group create -g $rgName -f ./bicep/main.bicep -p identityName=$identityName acrName=$acrName
