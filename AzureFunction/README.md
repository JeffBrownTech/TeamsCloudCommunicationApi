# TeamsCloudCommunicationAPI in Azure Function App

The code in **run.ps1** can be used inside an Azure Function App for exporting Microsoft Teams PSTN Usage Records to Azure table storage. To read more about the full solution, check out my blog post below:

**[Jeff Brown Tech | How to Export Teams PSTN Usage Records with Azure Functions](https://jeffbrown.tech/how-to-export-teams-pstn-usage-records-with-azure-functions)**

In the **run.ps1** file, you will need to update variables enclosed in brackets { } to match the settings in your Function App. These changes include the client ID, client secret, tenant ID, and the output binding to the Azure table storage.