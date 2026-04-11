# Blue Green deployment using Azure Traffic Manager

## Provision infrastructure

- terraform init -backend-config="azure.sas.conf" -reconfigure -upgrade
- terraform plan -out main.tfplan -lock=false
- terraform apply -lock=false "main.tfplan"
- .\Deploy-Blue-Page.ps1
- .\Deploy-Green-Page.ps1

## Swap slots using scripts

- .\Switch-To-Blue.ps1
- .\Switch-To-Green.ps1

## Cons and pros

## Comments

- Traffic can be **Weighted** or **Priority**
- **Weighted** is probabilistic (i.e blue 300 / green 700, total 1000)
- **Priority** gives the highest healthy target machine
- **Priority**: ascending order to values, for example priority over 3 endpoints: 1,2,3, the 1 gets all traffic if healthy, otherwise 2 gets the traffic etc.