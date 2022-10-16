#!/bin/bash

set -e

rgName="rg-aca-background-worker"

echo "Creating Resource Group..."
az group delete -n $rgName --yes --no-wait
