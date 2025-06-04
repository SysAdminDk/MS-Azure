<#

    .DESCRIPTION
        Auth to Azure management API with Device Code.


    .EXAMPLES
        $ManagementToken  = Get-DeviceAuth -Scope "https://management.azure.com/.default"
        $GraphAccessToken = Get-DeviceAuth -Scope "https://graph.microsoft.com/.default"
        $VaultAccessToken = Get-DeviceAuth -Scope "https://vault.azure.net/.default"
        $StorageToken     = Get-DeviceAuth -Scope "https://storage.azure.com/.default"

#>

function Get-DeviceAuth {
    param (
        [Parameter(Mandatory=$true)][string]$Scope
    )    

    $AuthResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$EntraTenantID/oauth2/v2.0/devicecode" -Body @{
        client_id = "d3590ed6-52b3-4102-aeff-aad2292ab01c"
        scope = "$Scope"
    }

    Write-Host $AuthResponse.Message
    $AuthResponse.Message -match "enter the code (\w{9})" | Out-Null

    # Copy the code  to Clipboard
    $matches[1] | Set-Clipboard

    # Start browser
    Start-Process -FilePath "msedge.exe" -ArgumentList "https://microsoft.com/devicelogin"

    # Retrive the token.
    do {
        try {
            $TokenQuery = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$EntraTenantID/oauth2/v2.0/token" -Body @{
                client_id = "d3590ed6-52b3-4102-aeff-aad2292ab01c"
                grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                device_code = $AuthResponse.device_code
            }
            return $TokenQuery.access_token
        }
        catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 5
        }
    } until ($false)
}
