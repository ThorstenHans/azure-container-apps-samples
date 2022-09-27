#!/bin/bash

set -e

rgName="rg-aca-single-container"

echo "Creating Resource Group..."
az group delete -n $rgName --no-wait
