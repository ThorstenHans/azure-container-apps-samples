#!/bin/bash

set -e

echo "Adding Azure Container Apps extension to Azure CLI"
# az extension add --source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.0-py2.py3-none-any.whl

echo "Ensuring Microsoft.Web provider is registered with current Azure Subscription"
az provider register --namespace Microsoft.Web

rgName=rg-hello-aca
location=eastus
lawName=law-hello-aca
acaEnvironmentName=hello-aca
image=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest

echo "Creating Resource Group"
az group create -n $rgName -l $location
echo "Creating Log Analytics Workspace"
lawClientId=$(az monitor log-analytics workspace create --workspace-name $lawName -g $rgName --query customerId -o tsv)
lawClientSecret=$(az monitor log-analytics workspace get-shared-keys -n $lawName -g $rgName --query primarySharedKey -o tsv)

echo "Creating Azure Container App Environment"
az containerapp env create -n $acaEnvironmentName -g $rgName --logs-workspace-id $lawClientId --logs-workspace-key $lawClientSecret -l $location
echo ""

echo "Deploying Container to Azure Container App"
fqdn=$(az containerapp create -n hello-aca -g $rgName --environment $acaEnvironmentName --image $image --target-port 80 --ingress external --query configuration.ingress.fqdn -o tsv)
echo ""

echo -e "Our Azure Container App is up and running at https://${fqdn}"
