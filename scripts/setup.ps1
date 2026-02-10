#==================================================================================================
# Powershell Profile Setup Script
#==================================================================================================

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
function Write-BoxHeader {
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
}

function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

function Get-ProfileDir {
    if ($PSVersionTable.PSEdition -eq "Core") {
        return "$env:userprofile\Documents\PowerShell"
    } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        return "$env:userprofile\Documents\WindowsPowerShell"
    } else {
        Write-Error "Unsupported PowerShell edition: $($PSVersionTable.PSEdition)"
        break
    }
}

#==================================================================================================
# Profile Functions
#==================================================================================================
function Create-Profile {
    Clear-Host
    Write-BoxHeader "Creating Profile"

    if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
        try {
            $profilePath = Get-ProfileDir

            if (!(Test-Path -Path $profilePath)) {
                New-Item -Path $profilePath -ItemType "directory" -Force
            }

            Invoke-RestMethod https://raw.githubusercontent.com/at0ms/powershell-profile/refs/heads/main/profile/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
            Write-Host "Profile has been created." -ForegroundColor "Green"
            Write-Host "Please restart your PowerShell session to apply changes."
        }
        catch {
            Write-Error "Failed to create the profile. Error: $_"
        }
    } else {
        try {
            $backupPath = Join-Path (Split-Path $PROFILE) "old_powershell_profile.ps1"
            Move-Item -Path $PROFILE -Destination $backupPath -Force
            
            Invoke-RestMethod https://raw.githubusercontent.com/at0ms/powershell-profile/refs/heads/main/profile/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE

            Write-Host "Profile has been Updated." -ForegroundColor "Green"
            Write-Host "Please restart your PowerShell session to apply changes."
            Write-Host "Your old profile has been backed up to [$backupPath]"
        }
        catch {
            Write-Error "Failed to backup and update the profile. Error: $_"
        }
    }
}

function Remove-Profile {
    Clear-Host
    Write-BoxHeader "Removing Profile"

    if ((Test-Path -Path $PROFILE -PathType Leaf))
    {
        try {
            $backupPath = Join-Path (Split-Path $PROFILE) "old_powershell_profile.ps1"
            Move-Item -Path $PROFILE -Destination $backupPath -Force

            Write-Host "Profile has been removed." -ForegroundColor "Green"
            Write-Host "For safety, a backup of the profile has been created at [$backupPath]"
        }
        catch {
            Write-Error "Failed to backup and remove the profile. Error: $_"
        }
    }
}

#==================================================================================================
# Extras Functions
#==================================================================================================
function Install-Extras {
    Clear-Host
    Write-BoxHeader "Installing Extras"

    if(!$Commands.OhMyPosh) {
        try {
            Write-Host "Oh My Posh was not found. Installing now..." -ForegroundColor "DarkGray"
            winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh
        }
        catch {
            Write-Error "Failed to install Oh My Posh. Error: $_"
        }
    } else {
        Write-Host "Oh My Post already installed. Skipping."
    }
}

function Remove-Extras {
    Clear-Host
    Write-BoxHeader "Removing Extras"

    if($Commands.OhMyPosh) {
        try {
            Write-Host "Oh My Posh installation detected. Removing..." -ForegroundColor "DarkGray"
            winget remove JanDeDobbeleer.OhMyPosh
        }
        catch {
            Write-Error "Failed to remove Oh My Posh. Error: $_"
        }
    } else {
        Write-Host "Oh My Post not installed. Skipping."
    }
}

#==================================================================================================
# UI
#==================================================================================================
function Ask-YesNo {
    param([string]$Message)

    while ($true) {
        $answer = Read-Host "$Message (Y/N)"
        switch ($answer.ToUpper()) {
            "Y" { return $true }
            "N" { return $false }
            default { Write-Host "Please enter Y or N." -ForegroundColor Yellow }
        }
    }
}

function Pause-Terminal {
    Write-Host ""
    Read-Host "Press ENTER to continue"
}

function Draw-Menu {
    param(
        [string]$Title,
        [string[]]$Options
    )

    Write-BoxHeader $Title

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("[$($i+1)]  " + $Options[$i]) -ForegroundColor Gray
    }

    Write-Host ""
    while ($true) {
        $choice = Read-Host "Select an option"
        if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $Options.Count) {
            return $choice
        }
        Write-Host "Invalid selection." -ForegroundColor Yellow
    }
}

function Start-Main-Menu {
    Clear-Host

    $mainMenuItems = @(
        "Create/Update Profile",
        "Remove Profile",
        "Install Extras (Oh-My-Posh)",
        "Remove Extras (Oh-My-Posh)",
        "Exit"
    )

    $choice = Draw-Menu -Title "Main Menu" -Options $mainMenuItems

    switch ($choice) {
        1 {
            Create-Profile
            Pause-Terminal
        }
        2 {
            Remove-Profile
            Pause-Terminal
        }
        3 {
            Install-Extras
            Pause-Terminal
        }
        4 {
            Remove-Extras
            Pause-Terminal
        }
        5 {
            Write-Host "`nExiting installer." -ForegroundColor Red
            exit
        }
    }
}

#==================================================================================================
# Session Initialization
#==================================================================================================
Clear-Host

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}

# Check if user wanted to start the script
Write-BoxHeader -Title "Powershell Profile Setup Script"

if (-not (Ask-YesNo "Continue with setup?")) {
    Write-Host "`nSetup cancelled." -ForegroundColor Red
    exit
}

# If the user says 'yes' continue to draw the ui
Start-Main-Menu