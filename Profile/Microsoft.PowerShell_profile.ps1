#==================================================================================================
# Andy's Powershell Profile
#==================================================================================================
# Version: 1.0.0
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

#==================================================================================================
# Script Variables
#==================================================================================================
$Script:BasePath = Join-Path (Get-ProfileDir) "Profile"
$Script:ConfigFilePath = Join-Path $Script:BasePath "Config.json"
$Script:Config = {}

#==================================================================================================
# Command Cache
#==================================================================================================
$availableCommands = (Get-Command oh-my-posh -CommandType Application -ErrorAction Ignore).Name -replace '\.exe$', ''
$Commands = @{
    OhMyPosh = 'oh-my-posh' -in $availableCommands
}

#==================================================================================================
# Shortcuts
#==================================================================================================
if($Commands.OhMyPosh) {
    Set-Alias -Name omp -Value oh-my-posh
}

#==================================================================================================
# CLI
#==================================================================================================
function Invoke-ProfileCLI
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    if (-not $Args -or $Args.Count -eq 0) {
        Write-Host " "
        Write-Host "Profile CLI"
        Write-Host " "
        Write-Host "Usage:"
        Write-Host "  profile setup"
        Write-Host " "
        return
    }

    $command = $Args[0].ToLower()
    $rest    = $Args[1..($Args.Count - 1)]

    switch ($command)
    {
        "setup" {
            if(Test-GitHubConnection) {
                irm "https://github.com/at0ms/powershell-profile/raw/main/Scripts/setup.ps1" | iex
            } else {
                Write-Warning "Cannot connect to github.com. Please check your connection."
            }
        }

        default {
            throw "Unknown profile command: $command"
        }
    }
}

Set-Alias -Name profile -Value Invoke-ProfileCLI

#==================================================================================================
# Pre-Initialization
#==================================================================================================
if (-not (Test-Path $Script:BasePath)) {
    New-Item -ItemType Directory -Path $Script:BasePath | Out-Null
}

$Script:Config = Load-JsonConfig -Path $Script:ConfigFilePath -Default @{
    ClearConsoleOnInitialization = $true
    ConsoleUseUTF8 = $true
    Customization = @{
        OhMyPosh = $true
    }
}

#==================================================================================================
# Initialization
#==================================================================================================
if($Script:Config.ClearConsoleOnInitialization) {
    Clear-Host
}

if($Script:Config.ConsoleUseUTF8)
{
    # Ensure the console uses UTF‑8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # Ensure PowerShell uses UTF‑8 for external commands and pipelines.
    $OutputEncoding = [System.Text.Encoding]::UTF8

    # Make UTF‑8 the default for Out-File, Export-CSV, etc.
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

if($Script:Config.Customization.OhMyPosh)
{
    if($Commands.OhMyPosh)
    {
        $localThemePath = Join-Path $Script:BasePath "theme.omp.json"

        if (-not (Test-Path $localThemePath))
        {
            Write-Warning "Oh My Posh theme not found!, attempting to download."
            $themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json"

            try {
                Invoke-RestMethod -Uri $themeUrl -OutFile $localThemePath
                Write-Host "Downloaded missing Oh My Posh theme to $localThemePath"
            } catch {
                Write-Warning "Failed to download theme file. Falling back to remote theme. Error: $_"
            }
        }

        if (Test-Path $localThemePath) {
            oh-my-posh init pwsh --config $localThemePath | Invoke-Expression
        } else {
            oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
        }
    }
}