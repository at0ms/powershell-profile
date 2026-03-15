#==================================================================================================
# Andy's Powershell Profile
#==================================================================================================
# Version: 1.0.1
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

function Test-GitHubConnection {
    if ($PSVersionTable.PSEdition -eq "Core") {
        # If PowerShell Core, use a 1 second timeout.
        return Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1
    } else {
        # For PowerShell Desktop, use .NET Ping class with timeout.
        $ping = New-Object System.Net.NetworkInformation.Ping
        $result = $ping.Send("github.com", 1000) # 1 second timeout.
        return ($result.Status -eq "Success")
    }
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
$Script:ConfigFilePath = Join-Path $Script:BasePath "config.json"
$Script:Config = {}
$Script:CommandRegistry = @{}
$Script:AliasRegistry = @{}

#==================================================================================================
# Command Cache
#==================================================================================================
$availableCommands = (Get-Command oh-my-posh, subl, code, codium -CommandType Application -ErrorAction Ignore).Name -replace '\.exe$', ''
$Commands = @{
    OhMyPosh = 'oh-my-posh' -in $availableCommands
    SublimeText = 'subl' -in $availableCommands
    VSCode = 'code' -in $availableCommands
    VSCodium = 'codium' -in $availableCommands
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
        Write-Host "  profile invoke <command>"
        Write-Host "  profile get-commands"
        Write-Host "  profile config-edit"
        Write-Host "  profile config-reload"
        Write-Host " "
        return
    }

    $command = $Args[0].ToLower()
    if ($Args.Count -gt 1) {
        $rest = @($Args[1..($Args.Count - 1)])
    } else {
        $rest = @()
    }

    switch ($command)
    {
        "setup" {
            if(Test-GitHubConnection) {
                irm "https://github.com/at0ms/powershell-profile/raw/main/Scripts/setup.ps1" | iex
            } else {
                Write-Warning "Cannot connect to github.com. Please check your connection."
            }
        }

        "invoke" {
            if ($rest.Count -lt 1) {
                Write-Host "Usage: profile invoke <command>" -ForegroundColor Red
                break
            }
            
            Invoke-CommandByName -Name @rest
        }

        "get-commands" {
            Invoke-GetCommands
        }

        "config-edit" {
            Invoke-CommandByName edit $Script:ConfigFilePath
        }

        "config-reload" {
            $Script:Config = Load-JsonConfig -Path $Script:ConfigFilePath
            Write-Host "Reloaded config file." -ForegroundColor Green
        }

        default {
            throw "Unknown profile command: $command"
        }
    }
}

Set-Alias -Name profile -Value Invoke-ProfileCLI

#==================================================================================================
# Command System
#==================================================================================================
function Register-Command {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$Action,

        [string[]]$Alias,
        [string[]]$NativeAlias,

        [string]$Category,
        [string]$Description
    )

    # Store command metadata.
    $Script:CommandRegistry[$Name] = [pscustomobject]@{
        Action      = $Action
        Description = $Description
        Category    = $Category
    }

    # Internal aliases.
    if ($Alias) {
        foreach ($a in $Alias) {
            $Script:AliasRegistry[$a] = $Name
        }
    }

    # Native aliases -> wrapper functions.
    if ($NativeAlias)
    {
        foreach ($na in $NativeAlias)
        {
            $func = @"
param([Parameter(ValueFromRemainingArguments)]`$args)
Invoke-CommandByName '$Name' @args
"@

            Set-Item -Path "Function:\Global:$na" -Value ([scriptblock]::Create($func))

            $Script:AliasRegistry[$na] = $Name
        }
    }
}

function Invoke-CommandByName {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(ValueFromRemainingArguments)]
        $Args
    )

    # Resolve alias -> command.
    if ($Global:AliasRegistry.ContainsKey($Name)) {
        $Name = $Global:AliasRegistry[$Name]
    }

    if (-not $Global:CommandRegistry.ContainsKey($Name)) {
        throw "Command '$Name' not found."
    }

    $cmd = $Global:CommandRegistry[$Name]
    & $cmd.Action @Args
}

function Invoke-GetCommands {
    $results = foreach ($name in $Global:CommandRegistry.Keys) {
        $entry = $Global:CommandRegistry[$name]

        $aliases = $Global:AliasRegistry.GetEnumerator() |
                   Where-Object { $_.Value -eq $name } |
                   Select-Object -ExpandProperty Key

        # Split subcommands for grouping.
        $parts = $name -split ' '
        $main  = $parts[0]
        $sub   = if ($parts.Count -gt 1) { ($parts[1..($parts.Count-1)] -join ' ') } else { "" }

        [pscustomobject]@{
            Main        = $main
            Subcommand  = $sub
            Aliases     = if ($aliases) { $aliases -join ", " } else { "" }
            Category    = $entry.Category
            Description = $entry.Description
        }
    }

    $results |
        Sort-Object Main, Subcommand |
        Format-Table -AutoSize
}

#==================================================================================================
# Commands
#==================================================================================================
Register-Command -Name "greet" -Action {
    param($name)
    "Hello, $name"
} -NativeAlias "greet" -Category "Utility" -Description "Greets a user by name."

Register-Command -Name "edit-file" -Action {
    param($fileName)

    if($Script:Config.EditorOverride) {
        $editor = $Script:Config.Editor
    } else {
        $editor = if ($Commands.SublimeText) { 'subl' } # Sublime Text
        elseif ($Commands.VSCode) { 'code' } # VSCode
        elseif ($Commands.VSCodium) { 'codium' } # VSCodium
        else { "notepad" } # Default on windows
    }
    
    & $editor $fileName
} -NativeAlias "edit" -Category "Utility" -Description "Opens file in editor."

#==================================================================================================
# Pre-Initialization
#==================================================================================================
if (-not (Test-Path $Script:BasePath)) {
    New-Item -ItemType Directory -Path $Script:BasePath | Out-Null
}

$Script:Config = Load-JsonConfig -Path $Script:ConfigFilePath -Default @{
    ClearConsoleOnInitialization = $true
    ConsoleUseUTF8 = $true
    Editor = ""
    EditorOverride = $false
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