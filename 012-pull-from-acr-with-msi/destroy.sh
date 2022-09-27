#!/bin/bash

set -e

rgName="rg-aca-pull-via-msi"

echo "Deleting Resource Group"
az group delete --name $rgName --yes --no-wait
