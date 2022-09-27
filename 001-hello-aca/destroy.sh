#!/bin/bash

set -e

rgName=rg-aca-hello-world

echo "Deleting Resource Group '${rgName}'" 

az group delete -n $rgName --no-wait
