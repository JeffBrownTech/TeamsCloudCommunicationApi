# TeamsCloudCommunicationApi
PowerShell module that uses Cloud Communications Graph API calls to manage and to report on Microsoft Teams.

![Example of Get-TeamsPstnCalls function](https://jeffbrown.tech/wp-content/uploads/2020/08/GetTeamsPstnCallsExample.png)

*Disclaimer: Use of this code does not come with any support and is provided 'as-is'. Use at your own risk and review the code and test prior to use in production. This module uses the beta version of the Graph API, which is subject to change without notice from Microsoft.*

# Submitting Issues
If you run into any issues or errors using this module, please submit an Issue here in GitHub and I will review. If you have an enhancement, submit an issue and label it as an enhancement. I will implement as time allows.

# Getting Started
This module requires an Azure application registration in order to authenticate against the Graph API. This application registration requires Application permissions of **CallRecords.Read.PstnCalls**. Here is an example of what the application registration permissions should look like:

![App registration permissions](https://jeffbrown.tech/wp-content/uploads/2020/08/AzureAppRegistrationPermissions.png)

To read more about creating an Azure application registration, creating a client secret, and assigning permissions, check out my blog posts with references for additional reading:

[Getting Started with Microsoft Teams and Graph API](https://jeffbrown.tech/getting-started-with-microsoft-teams-and-graph-api/)

[Creating Microsoft Teams and Channels with Graph API and PowerShell](https://jeffbrown.tech/creating-microsoft-teams-and-channels-with-graph-api-and-powershell/)

# Importing the Module
After downloading the files in this repository, you can import the module for use in a PowerShell console by importing the .PSD1 file:

```powershell
Import-Module TeamsCloudCommunicationApi.psd1
```

You can then view the commands available in the module using the **Get-Command** cmdlet:

```powershell
Get-Command -Module TeamsCloudCommunicationApi
```

The module is available for download through the [PowerShell Gallery](https://www.powershellgallery.com/packages/TeamsCloudCommunicationApi) as well:

```powershell
Install-Module -Name TeamsCloudCommunicationApi
```

# Graph API Access Tokens
Part of using the Graph API is authenticating to the service to ensure you or your program can access and execute specific tasks. Included in this module is a function named **Get-GraphApiAccessToken**. This command takes two inputs: a PSCredential object and the Azure tenant ID. If you don't provide PSCredentials, the function will prompt for them.

The PSCredential object will use the application/client ID from the previous section as the user name, and the client secret will be the password. I suggest saving the output of this command to a variable to use in the remaining module functions.

Here is an example of saving the application/client ID and client secret to a variable, then using it when calling the function:

```powershell
$graphApiCreds = Get-Credential
```

![Saving credentials to a variable](https://jeffbrown.tech/wp-content/uploads/2020/08/SavingGraphApiCredsToVariable.png)

Use this as the value for the *-Credential* parameter along with the tenant ID to get the access token:

![Getting access token](https://jeffbrown.tech/wp-content/uploads/2020/08/GettingAccessToken.png)

As you can see, the value for the access token is a very long string, hence the suggestion to save to a variable. This access token is good for 1 hour or 3600 seconds. When this token expires, use this same command again to generate a new one.

# Getting Teams Call Usage Records
The Teams admin center has a report the displays all the call records made in the tenant. This report is incredibly useful for tracking costs of calls from communications credit usage, toll-free numbers, and audio conferencing dial-out. Prior to now there has not been a programmatic way of extracting these records, and admins have relied on exporting data manually from the admin center.

The new Teams call communication API has a method for extracting these call records and is divided between PSTN calls made using calling plans and calls made through direct routing. This *TeamsCloudCommunicatinApi* module has two commands to download these records: Get-TeamsPstnCalls and Get-TeamsDirectRoutingCalls.

Using the access token saved from the last section, you can use these commands to retrieve the call records. Both commands require you to specify a start and end date in the format YYYY-MM-DD. Both dates are in UTC and based on the call start time. The max days between the start and end date can be 90 days. If you want to gather all the calls in a single month, the start date will be the first day of the month, and the end date will be the first day of the following month. 

Here's an example of gathering all the records for the month of March 2020 using the access token variable generated from the last section:

```powershell
Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken
```

In this example, the call records will display on the screen. Other options include saving them to a variable, exporting to a CSV file, or converting to JSON:

```powershell
$march2020PstnRecords = Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken
```

```powershell
Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken | Export-Csv March2020.csv -NoTypeInformation
```

```powershell
Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken | ConvertTo-Json
```

Allowing the records to display as objects allows for manipulation of the results after retrieving the records. For example, if you are only interested in certain properties of each call record, use the **Select-Object** command to only export those properties:

```powershell
Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken | Select-Object duration, charge, callType, licenseCapability
```

![Using Select-Object to get specific properties](https://jeffbrown.tech/wp-content/uploads/2020/08/UsingSelectObject.png)

You can also use **Where-Object** to perform filtering on properties within the call records. For example, gather only the records where communications credits were used:

```powershell
Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-04-01 -AccessToken $accessToken | Where-Object -Property licenseCapability -EQ -Value 'MCOPSTNPP'
```

![Using Where-Object to filter results](https://jeffbrown.tech/wp-content/uploads/2020/08/UsingWhereObject.png)

# Future Improvements

- Perform date format validation
- Investigate if generating a refresh token is possible instead of manually generating a new one after 1 hour