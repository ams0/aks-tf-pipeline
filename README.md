# Introduction 

AKS Terraform with `azure-cli` `local-exec` via Azure DevOps pipelines. Work in progress

# Steps

First, non automated step to create the storage account and blob to store Terraform state (chicken/egg):

```
az group create -n tfstates
az storage account create -n tfstateblobs -g tfstates --sku STANDARD_LRS
az storage container create --account-name tfstateblobs --name tfstates
az role assignment create --role "Storage Blob Data Contributor" --assignee 852b9f60-7bd6-4cb9-b1b8-f2e34137b7bd --scope /subscriptions/12c7e9d6-967e-40c8-8b3e-4659a4ada3ef/resourcegroups/tfstates/providers/Microsoft.Storage/storageAccounts/tfstateblobs
```

Make sure you don't have a `ARM_ACCESS_KEY` environment variable set, but you have `ARM_CLIENT_ID`,`ARM_CLIENT_SECRET`,`ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` set to a Service Principal with Contributor access to the Storage account you created.

Create a Service Connection
Create a variable group


# Cluster validation

- Pull from ACR
- Create a LB service with private IP
# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)