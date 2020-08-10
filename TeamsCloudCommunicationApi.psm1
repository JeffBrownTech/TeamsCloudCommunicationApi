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
