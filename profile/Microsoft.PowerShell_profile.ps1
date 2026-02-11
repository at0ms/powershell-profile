#==================================================================================================
# Powershell Profile
#==================================================================================================
# Version: 1.0.4
#==================================================================================================

#==================================================================================================
# Global Variables
#==================================================================================================
$Global:VersionStr = "1.0.4"
$Global:SessionInitMessage = $false # (disabled by default).
$Global:HeaderWidth = 50
$Global:SectionPadding = 2
$Global:SectionOptionPadding = 2

#==================================================================================================
# Command Cache
#==================================================================================================

# Cache command existence checks for performance (single PATH search)
$availableCommands = (Get-Command oh-my-posh -CommandType Application -ErrorAction Ignore).Name -replace '\.exe$', ''
$Commands = @{
    OhMyPosh = 'oh-my-posh' -in $availableCommands
}

#==================================================================================================
# Utility Functions
#==================================================================================================
function Write-EmptyLine {
    Write-Host " "
}

function Write-Header {
    param(
        [string]$Title,
        [string]$TextColour = "Blue",
        [int]$Width = 50
    )

    # Calculate padding
    $paddingTotal = $Width - $Title.Length
    if ($paddingTotal -lt 0) { $paddingTotal = 0 }

    $padLeft  = [math]::Floor($paddingTotal / 2)
    $padRight = $paddingTotal - $padLeft

    # Build lines
    $lineTop    = "┌" + ("─" * $Width) + "┐"
    $lineBottom = "└" + ("─" * $Width) + "┘"
    $leftPad    = "│" + (" " * $padLeft)
    $rightPad   = (" " * $padRight) + "│"

    # Output
    Write-Host $lineTop
    Write-Host $leftPad -NoNewLine
    Write-Host $Title -ForegroundColor $TextColour -NoNewLine
    Write-Host $rightPad
    Write-Host $lineBottom
    
    Write-EmptyLine
}

function Write-Section {
    param(
        [string]$Title,
        [string]$TextColour = "Gray",
        [int]$Width = 40,
        [int]$LeftPadding = 2
    )

    # Build padding
    $pad = " " * $LeftPadding

    # Write title
    Write-Host ($pad + $Title) -ForegroundColor $TextColour

    # Write line
    Write-Host ($pad + ("─" * $Width))

    Write-EmptyLine
}

function Write-SectionOption {
    param(
        [string]$Text,
        [string]$TextColour = "Gray",
        [int]$LeftPadding = 2,
        [bool]$SameLine = $false
    )

    # Build padding
    $pad = " " * $LeftPadding

    # Write text
    if ($SameLine) {
        Write-Host ($pad + $Text) -ForegroundColor $TextColour -NoNewLine
    } else {
        Write-Host ($pad + $Text) -ForegroundColor $TextColour
    }
}

# Helper function for cross-edition compatibility
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

function Set-PSReadLineOptionsCompat {
    param([hashtable]$Options)
    
    if ($PSVersionTable.PSEdition -eq "Core") {
        Set-PSReadLineOption @Options
    } else {
        # Remove unsupported keys for Desktop and silence errors
        $SafeOptions = $Options.Clone()
        $SafeOptions.Remove('PredictionSource')
        $SafeOptions.Remove('PredictionViewStyle')
        Set-PSReadLineOption @SafeOptions
    }
}

#==================================================================================================
# Help Message
#==================================================================================================
function Show-Help {
    # Header
    Write-Header "Help" -Width $Global:HeaderWidth

    # General
    Write-Section "General" -Width ($Global:HeaderWidth - ($Global:SectionPadding * 2) + 2) -LeftPadding $Global:SectionPadding

    Write-SectionOption "psh" -LeftPadding $Global:SectionOptionPadding -SameLine $true -TextColour "Green"; Write-Host " - Shows this help message."
    Write-SectionOption "psi" -LeftPadding $Global:SectionOptionPadding -SameLine $true -TextColour "Green"; Write-Host " - Shows infomation about the script."
    Write-EmptyLine

    # Information
    Write-Section "Information" -Width ($Global:HeaderWidth - ($Global:SectionPadding * 2) + 2) -LeftPadding $Global:SectionPadding

    if ($Commands.OhMyPosh) {
        Write-SectionOption "oh-my-posh: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host "Installed" -ForegroundColor "Green"
    } else {
        Write-SectionOption "oh-my-posh: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host "Not Installed" -ForegroundColor "Red";
    }

    # Footer
    Write-EmptyLine
    Write-Header "" -Width $Global:HeaderWidth
}

#==================================================================================================
# Information Message
#==================================================================================================
function Show-Information {
    # Header
    Write-Header "Information" -Width $Global:HeaderWidth
    
    # Information
    Write-SectionOption "Version: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host $Global:VersionStr -ForegroundColor "Blue"
    Write-SectionOption "Developer: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host "Andy" -ForegroundColor "Blue"
    
    Write-EmptyLine

    Write-SectionOption "Github: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host "https://github.com/at0ms/powershell-profile" -ForegroundColor "Blue"
    Write-SectionOption "Release Notes: " -LeftPadding $Global:SectionOptionPadding -SameLine $true; Write-Host "https://github.com/at0ms/powershell-profile/blob/main/release-notes.md" -ForegroundColor "Blue"

    # Footer
    Write-EmptyLine
    Write-Header "" -Width $Global:HeaderWidth
}

#==================================================================================================
# Custom Command Aliases
#==================================================================================================
Set-Alias -Name psh -Value Show-Help
Set-Alias -Name psi -Value Show-Information

#==================================================================================================
# Session Initialization
#==================================================================================================
Clear-Host

# Ensure the console uses UTF‑8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ensure PowerShell uses UTF‑8 for external commands and pipelines
$OutputEncoding = [System.Text.Encoding]::UTF8

# Make UTF‑8 the default for Out-File, Export-CSV, etc.
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Presents a message on session initialization for users seeking a less minimal interface (disabled by default).
if ($Global:SessionInitMessage) {
    Write-Host "Andy's Powershell Profile" -ForegroundColor "Blue"
    Write-Host "Use '" -NoNewLine; Write-Host "psh" -ForegroundColor "Blue" -NoNewLine; Write-Host "' to display help information.";
    Write-EmptyLine
}

# Validate Oh My Posh Installation and Load Theme
if($Commands.OhMyPosh)
{
    $localThemePath = Join-Path (Get-ProfileDir) "theme.omp.json"

    if (-not (Test-Path $localThemePath)) {
        Write-Warning "Oh My Posh theme not found!, attempting to download."

        # Try to download the theme file to the detected local path.
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
        # Fallback to remote theme if local file doesn't exist.
        oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
    }
}

# Configures PSReadLine with custom syntax colors and improved history/prediction settings.
$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'  # SkyBlue (pastel)
        Parameter = '#98FB98'  # PaleGreen (pastel)
        Operator = '#FFB6C1'  # LightPink (pastel)
        Variable = '#DDA0DD'  # Plum (pastel)
        String = '#FFDAB9'  # PeachPuff (pastel)
        Number = '#B0E0E6'  # PowderBlue (pastel)
        Type = '#F0E68C'  # Khaki (pastel)
        Comment = '#D3D3D3'  # LightGray (pastel)
        Keyword = '#8367c7'  # Violet (pastel)
        Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
    }
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}
Set-PSReadLineOptionsCompat -Options $PSReadLineOptions

# Remove sensitive information from command history
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}