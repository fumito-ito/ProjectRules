#!/bin/bash

# 環境変数から設定を読み込む
SERVICE_NAME=${SERVICE_NAME:?'SERVICE_NAME is required'}
LOCAL_IMAGE_NAME=${LOCAL_IMAGE_NAME:?'LOCAL_IMAGE_NAME is required'}
PROJECT_ID=${PROJECT_ID:?'PROJECT_ID is required'}
REGISTRY=${PROJECT_ID}/${LOCAL_IMAGE_NAME}
REGION=${REGION:-'us-central1'}
ENVIRONMENT=${ENVIRONMENT:-'prod'}

docker tag $LOCAL_IMAGE_NAME gcr.io/$REGISTRY

docker push gcr.io/$REGISTRY

gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$REGISTRY \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars ENVIRONMENT=$ENVIRONMENT
