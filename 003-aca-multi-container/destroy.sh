#!/bin/bash

set -e

rgName=rg-aca-multi-container

echo "Deleting Resource Group '${rgName}'" 

az group delete -n $rgName
