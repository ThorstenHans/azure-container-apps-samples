#!/bin/bash

set -e

rgName="rg-aca-single-container"
location="northeurope"

echo "Creating Resource Group..."
az group create -n $rgName -l $location

echo ""
echo "Starting Azure Container Apps Deployment..."
az deployment group create -g $rgName -f ./bicep/main.bicep
