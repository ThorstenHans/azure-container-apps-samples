#!/bin/bash

az containerapp up --source . --name test --ingress external --target-port 8080
