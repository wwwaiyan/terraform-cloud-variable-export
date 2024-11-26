#!/bin/bash
##User Input for Terraform Cloud
read -sp "Enter the Terraform Cloud API Token: " TFC_TOKEN
echo 
read -p "Enter the Organization Name: " ORG_NAME
read -p "Enter the Workspace Name: " WORKSPACE_NAME
read -p "Enter the tfvars file name (press Enter for default 'terraform.tfvars'): " TFVARS_FILE

# Set default value for TFVARS_FILE if not provided
TFVARS_FILE=${TFVARS_FILE:-terraform.tfvars}

# Retrieve the Workspace ID using the provided workspace name and token
WORKSPACE_ID=$(curl \
  --silent \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/$ORG_NAME/workspaces/$WORKSPACE_NAME | jq -r '.data.id')

# Check if the workspace ID was retrieved successfully
if [[ -z "$WORKSPACE_ID" || "$WORKSPACE_ID" == "null" ]]; then
  echo "Error: Unable to retrieve workspace ID. Please check your token and workspace name."
  exit 1
fi

# Fetch and save Terraform variables to the specified tfvars file
curl \
  --silent \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/vars | \
  jq -r '.data[] | select(.attributes.category=="terraform") | "\(.attributes.key) = \"\(.attributes.value)\""' > "$TFVARS_FILE"

echo "Terraform variables have been saved to $TFVARS_FILE."
echo "Don't forget to cleanup variables files after use."
