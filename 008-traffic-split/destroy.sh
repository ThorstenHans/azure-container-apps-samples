#!/bin/bash

set -e

rgName=rg-aca-traffic-split

echo "Deleting Resource Group '${rgName}'" 

az group delete -n $rgName --no-wait
