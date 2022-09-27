#!/bin/bash

set -e

rgName="rg-aca-multi-container"
location="germanywestcentral"
acrName="acasample03"
echo "Creating Resource Group"

az group create -n $rgName -l $location

echo "Creating Azure Container Registry"
az acr create -n $acrName -g $rgName --sku Basic --admin-enabled true

echo "Building Container Images"
cd facade
docker build -t $acrName.azurecr.io/facade:latest .
cd ..

cd order
docker build -t $acrName.azurecr.io/orders:latest .
cd ..

cd inventory
docker build -t $acrName.azurecr.io/inventory:latest .
cd .. 

echo "Pushing Container Images to ACR"
az acr login -n $acrName
docker push $acrName.azurecr.io/facade:latest
docker push $acrName.azurecr.io/orders:latest
docker push $acrName.azurecr.io/inventory:latest

echo "Please set ACR_SERVER, ACR_ADMIN_USERNAME and ACR_ADMIN_PASSWORD"
echo "ACR_SERVER=$acrName.azurecr.io"
echo "ACR_ADMIN_USERNAME=$acrName"
echo ""
echo "grab the admin password using 'p=$(az acr credential show -n $acrName --query 'passwords[0].value' -o tsv)'"
echo "ACR_ADMIN_PASSWORD=$p"
