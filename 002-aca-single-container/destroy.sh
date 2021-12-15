#!/bin/bash

set -e

rgName="rg-aca-single-container"
location="northeurope"

echo "Creating Resource Group..."
az group delete -n $rgName -l $location --yes --no-wait
