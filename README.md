#### Create Resource Group

```
az group create --name <name-of-your-resource-group> --location <one-of-the-above-locations>
```

#### Deploy Bicep
```
az deployment group create --resource-group <name-of-your-resource-group> --template-file <your-bicep-file>.bicep --parameters --<your-parameter-file>.json

```

#### Reference:

[creating-and-provisioning-azure-container-apps-with-bicep](https://dev.to/willvelida/creating-and-provisioning-azure-container-apps-with-bicep-4gfb)