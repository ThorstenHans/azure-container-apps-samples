#! /bin/bash

rgName=aca-custom-health-probes

echo "Creating Resource Group"
az group create -n $rgName -l northeurope

az deployment group create -g $rgName -f ./bicep/main.bicep
