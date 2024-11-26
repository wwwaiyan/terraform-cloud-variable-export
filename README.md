# Terraform Cloud Variable Export Script  

This script allows you to export variables from a Terraform Cloud workspace and save them locally. It's particularly useful for backing up variables.

---

## Features  
- Fetches variables from a Terraform Cloud workspace using the API.  
- Supports sensitive data masking during input.  
- Saves variables in `key = "value"` format compatible with `.tfvars`.  
- Allows custom filenames or defaults to `terraform.tfvars`.  

---

## Prerequisites  

1. **API Token**: Generate a Terraform Cloud API token from your [Terraform Cloud Account Settings](https://app.terraform.io/app/settings/tokens).  
2. **Required Tools**:  
   - `curl`  
   - `jq`  

3. **Environment**:  
   - Linux or macOS.  
   - Windows with WSL installed.  

---

## Usage  

### 1. Clone the Repository  
```bash
git clone https://github.com/your-username/terraform-cloud-variable-export.git
cd terraform-cloud-variable-export
```
### 2. Run the Script
```bash
bash export_variables.sh
```
### 3. Provide the Required Inputs
- API Token: Paste your Terraform Cloud API token.   
- Organization Name: Enter your Terraform Cloud organization name.  
- Workspace Name: Enter the name of the workspace from which you want to export variables.  
- Filename: (Optional) Specify a name for the exported .tfvars file. If left blank, the script defaults to terraform.tfvars.  

## Example

```
Enter the Terraform Cloud API Token: ********************
Enter the Organization Name: my-organization
Enter the Workspace Name: my-workspace
Enter the tfvars file name (press Enter for default 'terraform.tfvars'): variables.tfvars
```

## Script
```bash
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

```

## Notes
- Sensitive Data Handling: Be cautious with sensitive variables in the exported file. Ensure it is securely stored and cleaned up after use.
- Error Handling: If the script fails, verify that:
    - The API token is valid.
    - The organization and workspace names are correct.
    - `curl` and `jq` are installed and accessible.  


> This script was created for knowledge sharing purposes. If you find it useful, consider giving it a ⭐ on GitHub.