RESOURCE=tutoriais
ACR=tutoriais
REGISTRY=${ACR}.azurecr.io
MONGO_DNS=mongodb
APP_NAME=nodejs-with-mongodb-api-example
IMAGE_NAME=$REGISTRY/$APP_NAME 


sudo az group create --name $RESOURCE --location eastus

echo '--------------------CONTAINER REGISTRY------------------------------'

az acr create --resource-group $RESOURCE --name $ACR --sku Basic --admin-enabled true
az acr login --name $ACR

#sudo docker tag api $IMAGE_NAME
sudo docker push   $IMAGE_NAME

echo '--------------------CONTAINER SERVICES------------------------------'


echo 'creating mongodb'
 
az container create --resource-group $RESOURCE\
  --name $MONGO_DNS --image mongo:3.5 \
  --cpu 1 --memory 1 --registry-username $ACR \
  --port 27017 \
  --ip-address public

echo 'getting acr pass'

ACR_PASS=$(az acr credential show -n $ACR --query passwords[0].value)
ACR_PASS="${ACR_PASS//\"}"

echo 'getting mongoDb IP'

MONGO_IP=$(az container show --resource-group $RESOURCE --name $MONGO_DNS --query ipAddress.ip)
MONGO_IP="${MONGO_IP//\"}"

echo 'creating application'

az container create --resource-group $RESOURCE\
  --name $APP_NAME --image $IMAGE_NAME\
  --cpu 1 --memory 1 \
  --registry-username $ACR\
  --registry-password $ACR_PASS \
  --port 4000 \
  --environment-variables MONGO_URL=$MONGO_IP\
  --ip-address public
  
az container logs --resource-group $RESOURCE --name $APP_NAME

az container delete --name $APP_NAME  --resource-group $RESOURCE --yes
az container delete --name $MONGO_DNS  --resource-group $RESOURCE --yes

az group delete -n $RESOURCE --yes
