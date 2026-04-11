$RG="rg-trafficmgr-d01"
$PROFILE_NAME="tm-profile-d01"

$ErrorActionPreference="Stop"

Write-Host "Switching traffic to GREEN..."

# Endpoints cannot have the same priority, thus 3 is used as swap variable

# Blue becomes secondary
az network traffic-manager endpoint update `
  --resource-group $RG `
  --profile-name $PROFILE_NAME `
  --name blue-endpoint-d01 `
  --type azureEndpoints `
  --priority 3

# Green becomes primary
az network traffic-manager endpoint update `
  --resource-group $RG `
  --profile-name $PROFILE_NAME `
  --name green-endpoint-d01 `
  --type azureEndpoints `
  --priority 1

# Blue becomes secondary
az network traffic-manager endpoint update `
  --resource-group $RG `
  --profile-name $PROFILE_NAME `
  --name blue-endpoint-d01 `
  --type azureEndpoints `
  --priority 2

Write-Host "Done. GREEN is now active." -ForegroundColor Green