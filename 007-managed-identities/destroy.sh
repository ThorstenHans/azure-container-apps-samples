#!/bin/bash

set -e

rgName="rg-aca-msi-sample"

echo "Creating Resource Group..."
az group delete -n $rgName --yes --no-wait
