function Get-GraphApiAccessToken {
    <#
        .SYNOPSIS
        Generates a Graph API access token.

        .DESCRIPTION
        Generates a Graph API access token using an Azure application registration client ID and client secret.
        This token can be used when making calls to Microsoft's Graph API.

        .OUTPUTS
        [System.String] Get-GraphApiAccessToken returns an access token string.

        .PARAMETER Credential
        Specifies a PSCredential object containing the application registration client ID and client secret.
        This parameter is optional.

        .PARAMETER TenantId
        Specifies the Tenant Id in GUID-format where the application registration was made.
        This parameter is mandatory.

        .EXAMPLE
        Get-GraphApiAccessToken -Tenant 86b3ffe7-2026-4846-b59f-fc96a3a9116f

        This example will prompt for the application/client ID and client secret using the Get-Credential cmdlet.

        .EXAMPLE
        $appCreds = Get-Credential
        Get-GraphApiAccessToken -Credential $appCreds -Tenant 86b3ffe7-2026-4846-b59f-fc96a3a9116f

        This examples saved the application/client ID and client secret to the variable $appCreds first.
        Then this value is passed to the function using the -Credential parameter.

        .NOTES
        It is suggested to saved the results of this function to a variable to use in other commands.
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(HelpMessage="Enter the application ID and client secret as a PSCredential object")]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory, HelpMessage = "Enter the Tenant Id GUID")]
        [string]
        $TenantId
    )

    [string]$appId = $null
    [string]$appSecret = $null

    if (-not ($PSBoundParameters.ContainsKey('Credential'))) {
        $Credential = Get-Credential -Message "User name = Application/Client ID | Password = Client Secret"
    }

    if ($Credential) {
        $appId = $Credential.UserName
        $appSecret = $Credential.GetNetworkCredential().Password

        $oauthUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

        $tokenBody = @{
            client_id     = $appId
            client_secret = $appSecret
            scope         = "https://graph.microsoft.com/.default"    
            grant_type    = "client_credentials"
        }

        $tokenRequestResponse = Invoke-RestMethod -Uri $oauthUri -Method POST -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -UseBasicParsing
        ($tokenRequestResponse).access_token
    }
    else {
        Write-Warning -Message "No credentials found, exiting command."
    }
} # End of Get-GraphApiAccessToken

function Get-TeamsPstnCalls {
    <#
        .SYNOPSIS
        Retrieves PSTN calls between a specified start and end date.

        .DESCRIPTION
        Uses Teams cloud communications Graph API call to retrieve PSTN usage data.
        Requires an Azure application registration with CallRecords.Read.PstnCalls permissions and Graph API access token.

        .OUTPUTS

        .PARAMETER StartDate
        The start date to search for records in YYYY-MM-DD format.

        .PARAMETER EndDate
        The end date to search for records in YYYY-MM-DD format.

        .PARAMETER AccessToken
        An access token for authorization to make Graph API requests.
        Recommended to save this value to a variable for resuse.

        .EXAMPLE
        Get-TeamsPstnCalls -StartDate 2020-03-01 -EndDate 2020-03-31 -AccessToken $accessToken

        This example retrieves PSTN usage records between 2020-03-01 and 2020-03-31 use an access toke
        saved to the variable $accessToken.

        .LINK
        https://docs.microsoft.com/en-us/graph/api/callrecords-callrecord-getpstncalls

        .NOTES
        The max duration between the StartDate and EndDate is 90 days.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage="Start date to search for call records in YYYY-MM-DD format")]
        [string]
        $StartDate,

        [Parameter(Mandatory, HelpMessage="End date to search for call records in YYYY-MM-DD format")]
        [string]
        $EndDate,

        [Parameter(Mandatory, HelpMessage="Access token string for authorization to make Graph API calls")]
        [string]
        $AccessToken
    )

    $headers = @{
        "Authorization" = $AccessToken
        "Content-type" = "application/json"
    }
    $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getPstnCalls(fromDateTime=$StartDate,toDateTime=$EndDate)"
    
    while (-not ([string]::IsNullOrEmpty($requestUri))) {
        $requestResponse = Invoke-RestMethod -Method GET -Uri $requestUri -Headers $headers

        $requestResponse.value

        if ($requestResponse.'@odata.NextLink') {
            $requestUri = $requestResponse.'@odata.NextLink'
        }
        else {
            $requestUri = $null
        }
    }
}

function Get-TeamsDirectRoutingCalls {
    <#
        .SYNOPSIS
        Retrieves direct routing calls between a specified start and end date.

        .DESCRIPTION
        Uses Teams cloud communications Graph API call to retrieve direct routing usage data.
        Requires an Azure application registration with CallRecords.Read.PstnCalls permissions and Graph API access token.

        .OUTPUTS

        .PARAMETER StartDate
        The start date to search for records in YYYY-MM-DD format.

        .PARAMETER EndDate
        The end date to search for records in YYYY-MM-DD format.

        .PARAMETER AccessToken
        An access token for authorization to make Graph API requests.
        Recommended to save this value to a variable for resuse.

        .EXAMPLE
        Get-TeamsDirectRoutingCalls -StartDate 2020-03-01 -EndDate 2020-03-31 -AccessToken $accessToken

        This example retrieves direct routing usage records between 2020-03-01 and 2020-03-31 use an access toke
        saved to the variable $accessToken.

        .LINK
        https://docs.microsoft.com/en-us/graph/api/callrecords-callrecord-getdirectroutingcalls

        .NOTES
        The max duration between the StartDate and EndDate is 90 days.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage="Start date to search for call records in YYYY-MM-DD format")]
        [string]
        $StartDate,

        [Parameter(Mandatory, HelpMessage="End date to search for call records in YYYY-MM-DD format")]
        [string]
        $EndDate,

        [Parameter(Mandatory, HelpMessage="Access token string for authorization to make Graph API calls")]
        [string]
        $AccessToken
    )

    $headers = @{
        "Authorization" = $AccessToken
        "Content-type" = "application/json"
    }
    $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getDirectRoutingCalls(fromDateTime=$StartDate,toDateTime=$EndDate)"
    
    while (-not ([string]::IsNullOrEmpty($requestUri))) {
        $requestResponse = Invoke-RestMethod -Method GET -Uri $requestUri -Headers $headers

        $requestResponse.value

        if ($requestResponse.'@odata.NextLink') {
            $requestUri = $requestResponse.'@odata.NextLink'
        }
        else {
            $requestUri = $null
        }
    }
}
