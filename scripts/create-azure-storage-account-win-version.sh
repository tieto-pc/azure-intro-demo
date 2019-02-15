#!/bin/bash

# Script adapted from https://docs.microsoft.com/en-us/azure/terraform/terraform-backend.
# We cannot create this storage account and blob container using Terraform itself since
# we are creating the remote state storage for Terraform and Terraform needs this storage in terraform init phase.

if [ $# -ne 4 ]
then
  echo "Usage: ./create-azure-storage-account.sh <location> <res-group-name> <storage-account-name> <container-name>"
  echo "Example: ./create-azure-storage-account.sh westeurope myname-azure-intro-demo-terraform-storage-rg devmynameintrodemoterrastorage dev-myname-intro-demo-terraform-container"

  echo "NOTE: Use the following azure cli commands to check the right account and to login to az.cmd first:"
  echo "  az.cmd account list --output table                    => Check which Azure accounts you have."
  echo "  az.cmd account set -s \"<your-azure-account-name>\"     => Set the right azure account."
  echo "  az.cmd login                                          => Login to azure cli."
  exit 1
fi


LOCATION=$1
RESOURCE_GROUP_NAME=$2
STORAGE_ACCOUNT_NAME=$3
CONTAINER_NAME=$4

# Create resource group
az.cmd group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az.cmd storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az.cmd storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az.cmd storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
echo "Add the access_key to your source file as:"
echo "  export ARM_ACCESS_KEY=<access_key>"
echo "And use the storage_account_name and container_name in dev.tf file"


