#!/bin/bash

set -e

rgName="rg-aca-multi-container"
location="northeurope"
echo "Creating Resource Group"

az group create -n $rgName -l $location
echo $ACR_SERVER
echo "Please ensure ACR_SERVER, ACR_ADMIN_USERNAME and ACR_ADMIN_PASSWORD are set. Hit Return to continue:"
read foo
echo ""
echo "Starting Deployment"
az deployment group create -g $rgName -f ./bicep/main.bicep -p containerRegistry=$ACR_SERVER containerRegistryUsername=$ACR_ADMIN_USERNAME containerRegistryPassword=$ACR_ADMIN_PASSWORD
