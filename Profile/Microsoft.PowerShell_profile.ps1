#==================================================================================================
# Andy's Powershell Profile
#==================================================================================================

#==================================================================================================
# Utility Functions
#==================================================================================================
function Save-JsonConfig {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [hashtable]$Data
    )

    $json = $Data | ConvertTo-Json -Depth 10
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Load-JsonConfig {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [hashtable]$Default = @{}
    )

    if (-not (Test-Path $Path)) {
        Save-JsonConfig -Path $Path -Data $Default
        return $Default
    }

    $raw = Get-Content -Path $Path -Raw
    return ($raw | ConvertFrom-Json)
}

function Get-ProfileDir {
    if ($PSVersionTable.PSEdition -eq "Core") {
        return [Environment]::GetFolderPath("MyDocuments") + "\PowerShell"
    } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        return [Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell"
    } else {
        Write-Error "Unsupported PowerShell edition: $($PSVersionTable.PSEdition)"
        return $null
    }
}