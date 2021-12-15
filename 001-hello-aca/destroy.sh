#!/bin/bash

set -e

rgName=rg-hello-aca

echo "Deleting Resource Group '${rgName}'" 

az group delete -n $rgName
