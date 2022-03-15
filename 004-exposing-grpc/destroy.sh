#!/bin/bash

set -e

rgName="rg-aca-grpc"

echo "Creating Resource Group..."
az group delete -n $rgName --yes --no-wait
