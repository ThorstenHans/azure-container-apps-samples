#! /bin/bash

name=traffic-split
rgName=rg-aca-traffic-split
az group create -n $rgName -l northeurope

az deployment group create -g $rgName -p name=$name -f ./bicep/traffic-split.bicep

echo "Deploying additional revisions..."

tags=( "space" "drunk" "hero" "devil" )
for t in "${tags[@]}"
do
    az containerapp update -n aca-$name -g $rgName --image thorstenhans/gopher:$t
done

echo "Now you can adjusting traffic split..."

