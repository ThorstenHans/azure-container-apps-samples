#!/bin/bash

set -e

echo "Adding Azure Container Apps extension to Azure CLI"
az extension add -n containerapp --upgrade

echo "Ensuring Microsoft.Web and Microsoft.App providers are registered with current Azure Subscription"
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.App


rgName=rg-hello-aca
location=northeurope

acaEnvironmentName=hello-aca
lawName=law-hello-aca
image=thorstenhans/gopher:hero

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
